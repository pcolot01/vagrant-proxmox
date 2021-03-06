# Vagrant Proxmox Provider

This is a [Vagrant](http://www.vagrantup.com) plugin that adds a [Proxmox](http://proxmox.com/) provider to Vagrant, 
allowing Vagrant to manage and provision Proxmox virtual machines.


## About this Fork

The primary motivation for this fork was to support the author's goals for managing Linux Containers (LXC) hosted in
Proxmox 5.2.6 on Microsoft Windows 10 platform. As such, this README and patches in this fork are tailored for this purpose. 
If you are interested in the original project, refer to the upstream [project](https://github.com/GastonGonzalez/vagrant-proxmox) . 

With this said, this fork has the following goals:
* Proxmox 5.2.6 APIs.
* Vagrant 2.1.2 APIs.
* Provide instructions for building and installing, under Microsoft Windows 10, the plugin locally.
* Provide instructions for testing using a local Proxmox 5.2.6 virtualized under Oracle VirtualBox. 
* Provide detailed instructions on configuring Proxmox to use a custom Vagrant-compatible Debian 9 container.
* Extend to Support configuration of the root password of the created lxc VM
* Extend to Support for qemu template cloning from telcat origin
* Extend to Support multiple NIC in lxc configuration

A TODO List is present at the bottom of this file.


## Requirements

* Vagrant 2.1.2+
* Ruby 2.5.1p57
* Promox 5.2.6 

## Building and Installing the Plugin (Windows 10)

The author's local development environment is an Windows 10 workstation. 


1. Install Ruby 2.5.1-2-x64 with MSYS2.

Download from https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-2.5.1-2/rubyinstaller-devkit-2.5.1-2-x64.exe
Install it with DevKit enabled for gem support

		$ rubyinstaller-devkit-2.5.1-2-x64.exe

2. Install rake.

Add-On from ruby

		$ gem install rake-compiler

or

Add-On from https://rubyinstaller.org/add-ons/rake-compiler.html

		$ git clone https://github.com/rake-compiler/rake-compiler.git rake-cpmpiler
		$ gem install rake-compiler

3. Verify that ruby is actually using 2.5.1.

        $ ruby -v
        ruby 2.5.1p57 (2018-03-29 revision 63029) [x64-mingw32]

4. Clone this project and build the plugin.

        $ git clone https://github.com/pcolot01/vagrant-proxmox.git
        $ cd vagrant-proxmox
        $ gem install bundler
        $ bundle install
        $ rake build

5. Uninstall the `vagrant-proxmox` plugin if exists and install the plugin locally.

        $ vagrant plugin uninstall vagrant-proxmox
        $ vagrant plugin install pkg/vagrant-proxmox-0.0.11.gem
        $ vagrant plugin list

6. Add the dummy Vagrant box for this provider.
   
        $ vagrant box add dummy dummy_box/dummy.box

> Note: For ongoing development, run the following to rebuild and reinstall the plugin.

  		$ rake build
		$ vagrant plugin uninstall vagrant-proxmox 
		$ vagrant plugin install pkg/vagrant-proxmox-0.0.11.gem

## Virtualize proxmox in Virtualbox to test locally (Optional)

- Install Virtualbox 5.2.18

- Create a VM under Virtualbax using the following parameters:

* General/Basic/Name: PromoxVE5
* General/Basic/Type: Linux
* General/Basic/Version: Debian(64-bit)
* System/Motherboard/Base Memory: 2048 MB
* System/Motherboard/Boot Order: Optical, Hard Disk
* System/Motherboard/Chipset: PIIX3
* System/Motherboard/Pointing Device: USB Tablet
* System/Motherboard/Extended Features: Enable I/O APIC, Hardware Clock in UTC Time
* System/Processor/Processor(s): 2
* System/Processor/Execution Cap: 100%
* System/Processor/Extended Features: Enable PAE/NX
* System/Acceleration/Paravirtualization Interface: Default
* System/Acceleration/Hardware Virtualization: Enable VT-x/AMD-V, Enable Nesting Paging
* Display/Screen/Video Memory: 16 MB
* Display/Screen/Monitor Count: 1
* Display/Screen/Scale Factor: 100%
* Storage/Controller:IDE/Name: IDE
* Storage/Controller:IDE/Type: PIIX4
* Storage/Controller:IDE/Use Host I/O Cache
* Storage/Controller:IDE/Optical Drive/Optical Drive: IDE Secondary Master
* Storage/Controller:IDE/Optical Drive/Browse: ProxmoxIso image during installation and empty after initial reboot of VM
* Storage/Controller:SATA/Name: SATA
* Storage/Controller:SATA/Type:AHCI
* Storage/Controller:SATA/Port Count: 1
* Storage/Controller:SATA/Hard Disk/Hard Disk: SATA Port 0
* Storage/Controller:SATA/Hard Disk/Information/Type(Format): Normal(VDI)
* Storage/Controller:SATA/Hard Disk/Information/Virtual Size: 201.67 GB
* Storage/Controller:SATA/Hard Disk/Information/Actual Size: 2.51 GB
* Storage/Controller:SATA/Hard Disk/Information/Details: Dynamically allocated differencing storage
* Storage/Controller:SATA/Hard Disk/Information/Location: D:\VirtualBox VMs\ProxmoxVE5\proxmoxVE5.vdi
* Storage/Controller:SATA/Hard Disk/Information/Attached to: proxmoxVE5 (initial)
* Audio/
* Network/Adaptater 1/Enable Network Adapter
* Network/Adaptater 1/Attached to: NAT
* Network/Adaptater 1/Advanced/Adaptater Type: Paravirtualized Network (virtio-net)
* Network/Adaptater 1/Advanced/Promiscuous Mode: Allow All
* Network/Adaptater 1/Advanced/MAC Address: xxxxxxxxxxxxxxxxx
* Network/Adaptater 1/Advanced/Cable Connected
* Network/Adaptater 2/Enable Network Adapter
* Network/Adaptater 2/Attached to: Host-only Adapter
* Network/Adaptater 2/Name: VirtualBox Host-Only Ethernet Adapter
* Network/Adaptater 2/Advanced/Adaptater Type: Paravirtualized Network (virtio-net)
* Network/Adaptater 2/Advanced/Promiscuous Mode: Allow All
* Network/Adaptater 2/Advanced/MAC Address: xxxxxxxxxxxxxxxxx
* Network/Adaptater 2/Advanced/Cable Connected
* Serial Ports/
* USB/Enable USB Controller
* USB/USB 2.0 (EHCI) Controller

* Global Tools/Host Network Manager/VirtualBox Host-Only Ethernet Adapter/Configure Manually/IPv4 Address: 169.254.100.1
* Global Tools/Host Network Manager/VirtualBox Host-Only Ethernet Adapter/Configure Manually/IPv4 Network Mask: 255.255.255.0

- Setup pve1.local pve1 pvelocalhost as the ip adress 169.254.100.3

Add the following line in the local hosts file or in your local DNS
```
169.254.100.3 pve1.local pve1 pvelocalhost
```

- Install Proxmox using the default network configuration
		
- Connect to pve1 server and update the followin files
 
/etc/hosts
```
127.0.0.1 localhost.localdomain localhost
169.254.100.3 pve1.local pve1 pvelocalhost
#10.0.2.3 pve1.local pve1 pvelocalhost

# The following lines are desirable for IPv6 capable hosts

::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
```

/etc/hostsname
```
pve1
```

The following network interface is specific to Virtualbox deployment.
The first NIC is mapped on the NAT first VirtualBox interface. This NIC is only used for OUTBOUND traffic from VirtualBox VM.
The second NIC is mapped on the Host-Only second VirtualBox interface. This NIC is used for INBOUND traffic to VirtualBox VM.
This NIC is part of the bridge vmbr1. Any Proxmox VM bridged to vmbr1 will be visible from the Microsoft Windows 10 Host.
The internal bridge vmbr0, is collecting the internal traffic and forward it to the first NIC OUTBOUND interface.

Using this network configuration, the proxmox server in VirtualBox, and all VM in proxmox are visible from the Microsoft Windows 10 
machine and are routing their outbound traffic thru the Microsoft Windows 10 workstation.

/etc/network/interfaces
```
# network interface settings; autogenerated
# Please do NOT modify this file directly, unless you know what
# you're doing.
#
# If you want to manage part of the network configuration manually,
# please utilize the 'source' or 'source-directory' directives to do
# so.
# PVE will preserve these directives, but will NOT its network
# configuration from sourced files, so do not attempt to move any of
# the PVE managed interfaces into external files!

# Loopback interface
auto lo
iface lo inet loopback


# Physical interface for traffic coming into the system.  Retag untagged
# traffic into vlan 1, but pass through other tags.
auto enp0s3
iface enp0s3 inet static
  address 10.0.2.3
  netmask 255.255.255.0
  gateway 10.0.2.2

# Physical interface for traffic coming into the system.  Retag untagged
# traffic into vlan 1, but pass through other tags.
auto enp0s8
iface enp0s8 inet manual

auto vmbr0
iface vmbr0 inet static
        address  10.10.10.1
        netmask  255.255.255.0
        bridge_ports none
        bridge_stp off
        bridge_fd 0
        post-up echo 1 > /proc/sys/net/ipv4/ip_forward
        post-up   iptables -t nat -A POSTROUTING -s '10.10.10.0/24' -o enp0s3 -j MASQUERADE
        post-down iptables -t nat -D POSTROUTING -s '10.10.10.0/24' -o enp0s3 -j MASQUERADE

auto vmbr1
iface vmbr1 inet static
        address 169.254.100.3
        netmask 255.255.255.0
        bridge_ports enp0s8
        bridge_stp off
        bridge_fd 0
```

/etc/resolv.conf
```
nameserver 172.16.0.1
nameserver 8.8.4.4	
```

- Apply the procedure to switch to free open source proxmox version

- Update proxmox

- Create VM

		Qemu VM to be configured without VT-x

- Create LXC

- Test network access from windows

		$ putty access to pve1: 169.254.100.3
		$ putty access to VM
		$ putty access to LCX

- Test network access from proxmox PVE1:

		$ ping www.google.com
		$ putty access to VM
		$ putty access to LCX	
		
## Extract Proxmox Virtual Environment private cetificate and pve private certificate

		Connect to proxmox using https://pve1:8006
		login as root
		select PVE node
		select certificate
		export both certificates
				
## Add Proxmox sel-signed CA certificate in your local Windows 10 trusted CA database

		$ C:\Windows\System32\mmc.exe C:\Windows\System32\certlm.msc 

	Select Certificates Local Computer\Trusted Root Certification Authorities\Certificates				
	Add both Proxmox Virtual Environment private cetificate and pve private certificate	
		
## Add Proxmox sel-signed CA certificate in your local Chrome trusted CA database

	Chrome option certificate Add...
        
## Create vagrant specific ssh key to avoid the default vagrant key 

	Refer to the [Add a CentOS 7 Container Image](https://www.gastongonzalez.com/tech-blog/2016/12/24/building-a-developer-virtualization-lab-part-2) section on my blog post for instructions.
		
## Create Vagrant-compatible Container

	Refer to the [Add a CentOS 7 Container Image](https://www.gastongonzalez.com/tech-blog/2016/12/24/building-a-developer-virtualization-lab-part-2) section on my blog post for instructions.


## Add a Promox User (Optional)

	Refer to the [Add a Promox User](https://www.gastongonzalez.com/tech-blog/2016/12/24/building-a-developer-virtualization-lab-part-2) sectopm on my blog post for instructions.

 
## Create a Vagrantfile and Provision

On your local workstation, create a `Vagrantfile`. Simply change:

   * `config.ssh.private_key_path` - This should point to the private key on your local workstation that was created earlier.  
   * `config.vm.hostname` - This should contain the VM hostname.
   * `config.vm.box_download_insecure` - This should be true.
   
   * `proxmox.endpoint` - This should be updated with the IP or hostname of your Proxmox server.
   * `proxmox.user_name` - This should be proxmox administrator user using the form user@pve for local pve user, or user@pam for linux user.
   * `proxmox.password` - This should be proxmox administrator user password using the form 999..999.
   * `proxmox.vm_id_range` - This should be the range in which the VM id is choosen.
   * `proxmox.vm_name_prefix` - This should be 'vagrant_'.
   * `proxmox.lxc_os_template` - This should be the template used to build the VM using the form 'local:vztmpl/debian-9-base_20180817_amd64.tar.xz'.
   * `proxmox.vm_type` - This should be the VM type :lxc for linux container and :qemu for linux VM.
   * `proxmox.vm_root_password` - This should be VM root password.
   * `proxmox.vm_memory` - This should be the memory allocated to the Container/VM by proxmox.
   * `proxmox.vm_storage` - This should be the storage location of the disk resources allocated by proxmox.
   * `proxmox.vm_disk_size` - This should be the disk size allocated by proxmox.
   
   * `box.vm.box` - This should be 'dummy'.
   * `box.vm.network. - This should be for each NIC. 
```
        box.vm.network :private_network, ip: '10.10.10.5', cidr_block: '/24', interface: 'eth0', bridge: 'vmbr0', gw: '10.10.10.1', hostsupdater: "skip"
        box.vm.network :public_network, ip: '169.254.100.5', cidr_block: '/24', interface: 'eth1', bridge: 'vmbr1', gw: '169.254.100.1'
```
   * `box.vm.network.type` - This should be :private_network, :public_network, :forward???. 
   * `box.vm.network.ip` - This should be the IP address. 
   * `box.vm.network.cidr_block` - This should be the netmask using the form '/24'. 
   * `box.vm.network.interface` - This should be the interface name. 
   * `box.vm.network.bridge` - This should be the bridge name. 
   * `box.vm.network.gw` - This should be the network gateway. 
   * `box.vm.network.hostsupdater` - This should be set to skip for all NIC except the first public one. 
   
This is a simple Vagrantfile of a container.
   
```
# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Set the private key to use to connect to proxmox
    config.ssh.private_key_path = 'C:\\Users\\Home\\.ssh\\vagrant'
	
  # Set the VM hostname
    config.vm.hostname = 'debian9-proxmox'
	config.vm.box_download_insecure = true
  
  # Set the VM provider
    config.vm.provider :proxmox do |proxmox|
        proxmox.endpoint = 'https://pve1:8006/api2/json'
        proxmox.user_name = 'vagrant@pve'
        proxmox.password = 'vagrant'
        proxmox.vm_id_range = 900..910
        proxmox.vm_name_prefix = 'vagrant_'
        proxmox.lxc_os_template = 'local:vztmpl/debian-9-base_20180817_amd64.tar.xz'
        proxmox.vm_type = :lxc
		proxmox.vm_root_password = 'vagrant'
        proxmox.vm_memory = 1024
        proxmox.vm_storage = 'local-lvm'
        proxmox.vm_disk_size = '50G'
    end
  
  
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  
    config.vm.define :box, primary: true do |box|
        box.vm.box = 'dummy'
        box.vm.network :private_network, ip: '10.10.10.5', cidr_block: '/24', interface: 'eth0', bridge: 'vmbr0', gw: '10.10.10.1', hostsupdater: "skip"
        box.vm.network :public_network, ip: '169.254.100.5', cidr_block: '/24', interface: 'eth1', bridge: 'vmbr1', gw: '169.254.100.1'
    end
  
  # The first public network is used as IP addredd for remote SSH connection
  
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network :forwarded_port, guest: 80, host: 4567
  
  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"


  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"
  #config.vm.network "private_network", ip: "192.168.99.99"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  #config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  #config.vm.synced_folder ".", "/vagrant_data"

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

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
  # config.vm.provision :shell, path: "bootstrap.sh"
end

```


## Provision a VM.

        $ vagrant up --provider=proxmox 

If you run into issues, add the `--debug` flag.


## ChangeLog

- Upgrade:: plugin version to 0.0.11
- Upgrade:: plugin dependencies to vagrant 2.1.2, etc
- Upgrade:: README.md to document Windows 10 installation, Proxmox under Virtualbox test environment and plugin usages

- Fix:: Remove old restclient cookie patch incompatible with new restclient API
- Fix:: Proxmox vagrant resync code duplication realign with plugin to support cygwin path under windows, leading / on path and improved error message_file_not_found but to be replaced by Official plugin call
- Fix:: Avoid lock in provider state acquisition by alignment with proxmox 5 plugin aws template
- Fix:: On destroy cleaning of files .vagrant/machines/#{env[:machine].name}/proxmox/* but conserve the parent directory to allow final cwd storage
- Fix:: Removal of container openvz support and Migration of template from openvz to lxc support in promox vagrant plugin

- Add:: Support configuration of the root password of the created lxc VM
- Add:: Support for qemu template cloning from telcat origin:
- Add:: Support multiple NIC in lxc configuration

- Cleanup:: Code formatting

	
## Issues: 

No pending issue


## Todo:

- Fix:: Remove in proxmox plugin the copy of sync folders and reuse existing rsync plugin
- Fix:: Align proxmox vagrant plugin with official version 5 aws vagrant plugin
- Add:: Support configuration of the root password of the created qemu VM:
- Add:: Support multiple NIC in qemu configuration:

- Review spec
- Review rake, telcat/Rake, automate test, rebuild, ...
- Complete all new scenario and apply tests 

