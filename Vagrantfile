Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  
  # Control Plane VM (Master)
  config.vm.define "master" do |master|
    master.vm.hostname = "master"
    master.vm.network "private_network", ip: "192.168.56.10"
    master.vm.provider "virtualbox" do |v|
      v.memory = 4096
      v.cpus = 2
      v.name = "k8s-master"
    end
    
    # Generate an SSH keypair on the master node to act as the Ansible Controller
    master.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update && sudo apt-get install -y ansible sshpass
      if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
        ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -q -N ""
        cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
        cp /home/vagrant/.ssh/id_rsa.pub /vagrant/master_id_rsa.pub
      fi
      chown -R vagrant:vagrant /home/vagrant/.ssh
    SHELL
  end

  # Worker VMs

  (1..3).each do |i|
    config.vm.define "worker#{i}" do |worker|
      worker.vm.hostname = "worker#{i}"
      worker.vm.network "private_network", ip: "192.168.56.1#{i}"
      worker.vm.provider "virtualbox" do |v|
        v.memory = 8192
        v.cpus = 4
        v.name = "k8s-worker#{i}"
      end

      # Trust the master's ssh key
      worker.vm.provision "shell", inline: <<-SHELL
        sudo mkdir -p /home/vagrant/.ssh
        # Copy the master's public key (Vagrant syncs to /vagrant)
        if [ -f /vagrant/master_id_rsa.pub ]; then
          cat /vagrant/master_id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
        fi
      SHELL
    end
  end
end
