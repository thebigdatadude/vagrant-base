# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.box = "nrel/CentOS-6.6-x86_64"
  #config.vm.box = "centos64"
  #config.vm.box_url = "https://github.com/tommy-muehle/vagrant-box-centos-6.6/releases/download/1.0.0/centos-6.6-x86_64.box"
  config.vm.provision "puppet"

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  # Ambari server
  config.vm.define "ambari" do |ambari|
    ambari.vm.box = "nrel/CentOS-6.6-x86_64"
    ambari.vm.network "forwarded_port", guest: 8080, host: 8080
    ambari.vm.hostname = "ambari.sandbox.thebigdatadude.com"
    ambari.vm.network "private_network", ip: "192.168.32.10"
  end


  # Nodes
  config.vm.define "node001" do |node001|
    node001.vm.box = "nrel/CentOS-6.6-x86_64"
    node001.vm.hostname = "node001.sandbox.thebigdatadude.com"
    node001.vm.network "private_network", ip: "192.168.32.31"
  end

  config.vm.define "node002" do |node002|
    node002.vm.box = "nrel/CentOS-6.6-x86_64"
    node002.vm.hostname = "node002.sandbox.thebigdatadude.com"
    node002.vm.network "private_network", ip: "192.168.32.32"
  end

  config.vm.define "node003" do |node003|
    node003.vm.box = "nrel/CentOS-6.6-x86_64"
    node003.vm.hostname = "node003.sandbox.thebigdatadude.com"
    node003.vm.network "private_network", ip: "192.168.32.33"
  end

  config.vm.define "node004" do |node004|
    node004.vm.box = "nrel/CentOS-6.6-x86_64"
    node004.vm.hostname = "node004.sandbox.thebigdatadude.com"
    node004.vm.network "private_network", ip: "192.168.32.34"
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL
end
