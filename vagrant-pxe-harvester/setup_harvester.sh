#!/bin/bash
# the vms default ipv4 addresses, found in settings.yml
default_vm_ipv4_addrs_arry=( 192.168.0.30 192.168.0.31 192.168.0.32 192.168.0.33 192.168.0.34 )
# the file location of the ssh known hosts
ssh_known_hosts_file=
# boolean to represent whether or not we will clean up IPs from VMs in the ssh hosts file
cleanup_known_ssh_hosts_bool=false
# boolean to represent whether or not we will be setting up for an airgapped rancher and airgapped harvester integration system
run_air_gapped_rancher_with_air_gapped_harvester=false
# boolean to represent whether or not harvester offline only is set
run_harvester_offline_only_no_rancher_running=false
# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-h/--help] [-skhf/--ssh-known-hosts-file] [FILE] [-cskh/--clean-ssh-known-hosts]...
Running the setup_harvester script we can specify whether or not to clean ssh known hosts, 
removing the IPs for each associated VM that is running, the list of VM's IPs are directly tied to settings.yml
IF there are any changes to settings.yml for IPs you must take into account that this functionality
does not automatically parse the settings.yml file at runtime, as these values are hardcoded.
If the -skhf | --ssh-known-hosts-file arguement is not provided but the -skhf | --ssh-known-hosts-file is
not provided, we will 'optimistically' use the default known hosts of ~/.ssh/known_hosts 

    -h | --help          display this help and exit
    -skhf | --ssh-known-hosts-file FILE the file to be used to for ssh known hosts, defaults to ~/.ssh/knon_hosts.
    -cskh | --clean-ssh-known-hosts when this flag is passed we will clean up the IPs associated with VMs on your known_hosts file.
    -ragri | --run-air-gapped-rancher-integration when this flag is passed we will be running airgapped rancher installation
    -ho | --harvester-offline-only when this flag is passed we will be running harvester offline only, no rancher
EOF
}
# bails out of program
die() {
    printf '%s\n' "$1" >&2
    exit 1
}

while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        -skhf|--ssh-known-hosts-file)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                ssh_known_hosts_file=$2
                shift
            else
                die 'ERROR: "-skhf / --ssh-known-hosts-file" requires a non-empty option argument.'
            fi
            ;;
        -ragri|--run-air-gapped-rancher-integration)
            run_air_gapped_rancher_with_air_gapped_harvester=true  # bool
            ;;
        -ho|--harvester-offline-only)
            run_harvester_offline_only_no_rancher_running=true  # bool
            ;;
        -cskh|--clean-ssh-known-hosts)
            cleanup_known_ssh_hosts_bool=true  # bool
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)               # Default case: No more options, so break out of the loop.
            break
    esac

    shift
done

if [ "$cleanup_known_ssh_hosts_bool" = true ] ; then
    echo 'Cleaning up VM IPs from ssh hosts file...'
    for ip_to_clean in "${default_vm_ipv4_addrs_arry[@]}"
    do
        if [ ! -z "${ssh_known_hosts_file}" ]; then
            ssh-keygen -f $ssh_known_hosts_file -R $ip_to_clean;
        else
            ssh-keygen -f ~/.ssh/known_hosts -R $ip_to_clean;
        fi
    done 
fi

printf 'Starting Ansible Playbooks, running with the configuration on settings.yml...'
echo ""
MYNAME=$0
ROOTDIR=$(dirname $(readlink -e $MYNAME))

if [ "$run_air_gapped_rancher_with_air_gapped_harvester" = true ] ; then
    pushd $ROOTDIR
    ENVIRONMENT=airgap VAGRANT_LOG=info ansible-playbook ansible/setup_harvester.yml --extra-vars "@settings_airgap.yml" && ENVIRONMENT=airgap VAGRANT_LOG=info ansible-playbook ansible/prepare_harvester_nodes.yml --extra-vars "@settings_airgap.yml" -i inventory
    ANSIBLE_PLAYBOOK_RESULT=$?
    popd
    exit $ANSIBLE_PLAYBOOK_RESULT
else
    if [ "$run_harvester_offline_only_no_rancher_running" = true ] ; then
        pushd $ROOTDIR
        ENVIRONMENT=harvester_offline VAGRANT_LOG=info ansible-playbook ansible/setup_harvester.yml --extra-vars "@settings_harvester_offline.yml"
        ANSIBLE_PLAYBOOK_RESULT=$?
        popd
        exit $ANSIBLE_PLAYBOOK_RESULT  
    else
        pushd $ROOTDIR
        VAGRANT_LOG=info ansible-playbook ansible/setup_harvester.yml --extra-vars "@settings.yml"
        ANSIBLE_PLAYBOOK_RESULT=$?
        popd
        exit $ANSIBLE_PLAYBOOK_RESULT
    fi
fi
