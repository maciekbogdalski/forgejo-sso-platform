#!/bin/bash

# Ensure correct permissions
sudo chown -R vagrant:vagrant /home/vagrant/.ansible

# Reinstall the community.docker collection with the correct ownership and permissions
rm -rf /home/vagrant/.ansible/collections/ansible_collections/community/docker
ansible-galaxy collection install community.docker --force

# Ensure the installed binaries are in PATH
export PATH=$PATH:/home/vagrant/.local/bin

# Add the path to .bashrc to make it persistent
if ! grep -Fxq "export PATH=\$PATH:/home/vagrant/.local/bin" ~/.bashrc; then
    echo 'export PATH=$PATH:/home/vagrant/.local/bin' >> ~/.bashrc
    source ~/.bashrc
fi

# Set correct permissions after installation
sudo chown -R vagrant:vagrant /home/vagrant/.ansible
