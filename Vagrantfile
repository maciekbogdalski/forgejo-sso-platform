### configuration parameters ###
NUM_TARGET = 2

# VMWare: see NAT network
MYNET = "192.168.73"

CPUS = 2
RAM = 2048

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
        name = j == 1 ? 'control' : "target#{j-1}"
        node.vm.provision :shell, :privileged => true, :inline => <<-SHELL
          if ! grep #{MYNET}.#{j+9} /etc/hosts; then
            echo '#{MYNET}.#{j+9} #{name}.vcc.local #{name}' >> /etc/hosts
          fi
        SHELL
      end

      # Re-enable SSH key provisioning for VCC-control node
      if i == 1
        # Install sshpass
        node.vm.provision :shell, :privileged => true, :inline => <<-SHELL
          apt-get update
          apt-get install -y sshpass
        SHELL

        # Ensure SSH key is generated and present
        node.vm.provision :shell, :privileged => false, :inline => <<-SHELL
          ls -la /home/vagrant/.ssh
          test -f /home/vagrant/.ssh/id_rsa || ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -q -P ""
        SHELL

        # Provision SSH keys to target nodes
        (2..NUM_TARGET+1).each do |j|
          node.vm.provision :shell, :privileged => false, :inline => <<-SHELL
            sshpass -p vagrant ssh-copy-id -o StrictHostKeyChecking=accept-new vagrant@target#{j-1}.vcc.local
          SHELL
        end

        # Configure Ansible
        node.vm.provision :shell, :privileged => false, :inline => <<-SHELL
          echo -e '[defaults]\npipelining = True\nhost_key_checking = False' > ~/.ansible.cfg
        SHELL
      end
    end
  end
end
