### configuration parameters ###
NUM_TARGET = 2

# VMWare: see NAT network
MYNET = "192.168.177"

CPUS = 4
RAM = 4096

DEFAULT_PROVIDER = 'vmware_workstation'

Vagrant.configure("2") do |config|
  (1..NUM_TARGET+1).reverse_each do |i|
    if i == 1 then
      name = "VCC-control"
      hostname = "control"
    else
      target_i = i - 1
      name = "VCC-target#{target_i}"
      hostname = "target#{target_i}"
    end

    config.vm.define name do |node|
      node.vm.box = "bento/ubuntu-20.04"
      node.vm.box_version = "202309.09.0"

      node.vm.hostname = hostname
      node.vm.network :private_network, ip: "#{MYNET}.#{i+9}"

      node.vm.provider :vmware_workstation do |v|
        v.gui = true
        v.vmx["displayname"] = name
        v.vmx["memsize"] = "#{RAM}"
        v.vmx["numvcpus"] = "#{CPUS}"
      end

      # Disable default sync
      node.vm.synced_folder '.', '/vagrant', disabled: true

      # Debug network configuration
      node.vm.provision :shell, :inline => <<-SHELL
        echo "Debug Info: IP Addresses for #{name}"
        ip addr show
        echo "Debug Info: Routing Table for #{name}"
        ip route show
      SHELL

      # Ensure /etc/hosts is correctly configured
      (1..NUM_TARGET+1).each do |j|
        node_name = j == 1 ? 'control' : "target#{j-1}"
        node.vm.provision :shell, :privileged => true, :inline => <<-SHELL
          if ! grep #{MYNET}.#{j+9} /etc/hosts; then
            echo '#{MYNET}.#{j+9} #{node_name}.vcc.local #{node_name}' >> /etc/hosts
          fi
        SHELL
      end

      if i == 1
        # Install necessary packages and generate SSH key
        node.vm.provision :shell, :privileged => true, :inline => <<-SHELL
          apt-get update
          apt-get install -y openssh-server openssh-client sshpass make ansible git docker.io python3-pip nfs-kernel-server
          usermod -aG docker vagrant
          systemctl restart nfs-kernel-server
          apt-get install -y python3-distutils
          pip3 install "ansible" --upgrade
          systemctl enable ssh
          systemctl start ssh

          # Change ownership and permissions
          chown -R vagrant:vagrant /home/vagrant
          chmod -R 755 /home/vagrant

          # Create .ansible directory and set permissions
          mkdir -p /home/vagrant/.ansible/tmp
          chown -R vagrant:vagrant /home/vagrant/.ansible
          chmod -R 700 /home/vagrant/.ansible
        SHELL

        node.vm.provision :shell, :privileged => false, :inline => <<-SHELL
          ssh-keygen -t rsa -b 2048 -f /home/vagrant/.ssh/id_rsa_vcc -N "" || true
          chmod 600 /home/vagrant/.ssh/id_rsa_vcc
          chmod 644 /home/vagrant/.ssh/id_rsa_vcc.pub
        SHELL

        node.vm.provision :shell, :privileged => false, :inline => <<-SHELL
          echo -e '[defaults]\npipelining = True\nhost_key_checking = False' > ~/.ansible.cfg
        SHELL

        node.vm.provision :shell, :inline => <<-SHELL
          if [ -d "/home/vagrant/exam-2023-2024-vcc_mb" ]; then
            rm -rf /home/vagrant/exam-2023-2024-vcc_mb
          fi

          # Clone the GitHub repository using the provided username and token
          git clone https://maciekbogdalski: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@github.com/VCC-course/exam-2023-2024-vcc_mb

          # Create or append to the inventory file
          INVENTORY_PATH="/home/vagrant/exam-2023-2024-vcc_mb/project/inventory"
          mkdir -p /home/vagrant/exam-2023-2024-vcc_mb/project
          echo "[control]" > $INVENTORY_PATH
          echo "control ansible_host=#{MYNET}.10 nfs_server_ip=#{MYNET}.10 ansible_user=vagrant ansible_private_key_file=/home/vagrant/.ssh/id_rsa_vcc" >> $INVENTORY_PATH

          echo "[target]" >> $INVENTORY_PATH
          for i in $(seq 1 #{NUM_TARGET}); do
            echo "target${i} ansible_host=#{MYNET}.$((i+10)) ansible_user=vagrant ansible_private_key_file=/home/vagrant/.ssh/id_rsa_vcc" >> $INVENTORY_PATH
          done

          echo "[all:vars]" >> $INVENTORY_PATH
          echo "ansible_python_interpreter=/usr/bin/python3" >> $INVENTORY_PATH

          # Ensure NFS configuration
          echo "/srv/nfs #{MYNET}.10/24(rw,sync,no_subtree_check,no_root_squash)" | sudo tee /etc/exports
          sudo exportfs -a
          sudo systemctl restart nfs-kernel-server

          # Disable firewall for NFS testing (remove if not needed)
          sudo ufw disable

          # Install Ansible collections
          cd /home/vagrant/exam-2023-2024-vcc_mb/project
          echo "---\ncollections:\n  - name: community.docker" > requirements.yml
          ansible-galaxy collection install -r requirements.yml
          ansible-galaxy collection install community.docker

          # Create vault password file
          echo 'your_vault_password' > /home/vagrant/.ansible_vault_password
          chown vagrant:vagrant /home/vagrant/.ansible_vault_password
          chmod 600 /home/vagrant/.ansible_vault_password

          # Update Makefile with dynamic IPs
          sed -i 's/192.168.231.10/#{MYNET}.10/g' /home/vagrant/exam-2023-2024-vcc_mb/project/Makefile
          sed -i 's/192.168.231.11/#{MYNET}.11/g' /home/vagrant/exam-2023-2024-vcc_mb/project/Makefile
          sed -i 's/192.168.231.12/#{MYNET}.12/g' /home/vagrant/exam-2023-2024-vcc_mb/project/Makefile

          # Add a delay to allow target VMs to boot up
          echo "Waiting for target VMs to boot up..."
          sleep 90

          # Execute the SSH key distribution script
          sed -i 's/MYNET=.*/MYNET=#{MYNET}/' /home/vagrant/exam-2023-2024-vcc_mb/project/setup_ssh_keys.sh
          bash /home/vagrant/exam-2023-2024-vcc_mb/project/setup_ssh_keys.sh
        SHELL

        node.vm.provision :shell, :inline => <<-SHELL
          cd /home/vagrant/exam-2023-2024-vcc_mb/project
          ansible-playbook -i inventory deploy_ssh_keys.yml

          # Run make setup-all
          make setup-all

          # Change the starting directory to ~/exam-2023-2024-vcc_mb/project
          echo "cd ~/exam-2023-2024-vcc_mb/project" >> /home/vagrant/.bashrc
        SHELL
      else
        node.vm.provision :shell, :privileged => true, :inline => <<-SHELL
          apt-get update
          apt-get install -y openssh-server openssh-client docker.io python3-pip
          usermod -aG docker vagrant
          systemctl enable ssh
          systemctl start ssh

          # Change ownership and permissions
          chown -R vagrant:vagrant /home/vagrant
          chmod -R 755 /home/vagrant

          # Create .ansible directory and set permissions
          mkdir -p /home/vagrant/.ansible/tmp
          chown -R vagrant:vagrant /home/vagrant/.ansible
          chmod -R 700 /home/vagrant/.ansible
        SHELL
      end
    end
  end
end
