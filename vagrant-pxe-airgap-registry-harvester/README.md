# Notes

- ansible-galaxy collection install ansible.posix
- region on minio is being set, but in the ui will display as empty...
- ansible-galaxy collection install ansible.posix
- ansible-galaxy collection install community.docker
- ansible-galaxy collection install kubernetes.core
- other elements are needed from basic airgap, cross check those requirements ansible-galaxy ansible.posix is a new addition


## Docker-Registry
- depends on setup of openvswitch network: https://gist.github.com/irishgordo/487aa43eeff52fab47352a62290a8c78


### Run Ex:
```
ANSIBLE_VERBOSITY=4 ANSIBLE_ENABLE_TASK_DEBUGGER=True ansible-playbook ansible/setup_vagrant_vms.yml --extra-vars "@settings.yml"

```