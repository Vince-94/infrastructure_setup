# Ansible Playbooks

Ansible is a tool that allows to configure properly a machine.


## Install dependencies

1. Install Git
    ```
    sudo add-apt-repository universe
    sudo apt update
    sudo apt install git -y
    ```

2. Clone repo
    ```
    git clone <https_address>
    ```

3. Install Ansible
    ```
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt install ansible
    ```

## Configure environment

```sh
ansible-playbook -K main.yml
```

**Note:** Custom configuration is possible through the file "config.yaml".

