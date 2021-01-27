# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define :master do |master|
    master.vm.box = "hashicorp/bionic64"
    master.vm.hostname = "master"
    master.vm.synced_folder "srv/", "/srv"
    master.vm.network "private_network", ip: "192.168.33.10"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
    master.vm.provision "shell", inline: <<-SHELL
      add-apt-repository ppa:saltstack/salt -y
      apt-get update -y
      apt-get install salt-minion salt-master -y
      echo -e '192.168.33.10\tmaster salt' >>/etc/hosts
      echo -e '192.168.33.11\tminion-1' >>/etc/hosts
      echo -e '192.168.33.12\tminion-2' >>/etc/hosts
      echo -e '192.168.33.13\tminion-3' >>/etc/hosts
    SHELL
  end

  (1..3).each do |i|
    config.vm.define "minion-#{i}" do |minion|
      minion.vm.box = "hashicorp/bionic64"
      minion.vm.hostname = "minion-#{i}"
      minion.vm.network "private_network", ip: "192.168.33.1#{i}"
      minion.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
      end
      minion.vm.provision "shell", inline: <<-SHELL
        add-apt-repository ppa:saltstack/salt -y
        apt-get update -y
        apt-get install salt-minion -y
        echo -e '192.168.33.10\tmaster salt' >>/etc/hosts
        echo -e '192.168.33.11\tminion-1' >>/etc/hosts
        echo -e '192.168.33.12\tminion-2' >>/etc/hosts
        echo -e '192.168.33.13\tminion-3' >>/etc/hosts
      SHELL
    end
  end
end
