# Notes

- ansible-galaxy collection install ansible.posix
- ansible-galaxy collection install community.docker
- ansible-galaxy collection install kubernetes.core
- other elements are needed from basic airgap, cross check those requirements ansible-galaxy ansible.posix is a new addition


## Docker-Registry
- depends on setup of openvswitch network: https://gist.github.com/irishgordo/487aa43eeff52fab47352a62290a8c78


### Run Ex:
```
ANSIBLE_VERBOSITY=4 ANSIBLE_ENABLE_TASK_DEBUGGER=True ansible-playbook ansible/setup_rancher_and_docker.yml --extra-vars "@settings.yml"
```