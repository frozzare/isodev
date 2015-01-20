# -*- mode: ruby -*-
# vi: set ft=ruby :

# The hostname to use
HOSTNAME = 'isodev'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Virtualbox configuration
  config.vm.provider :virtualbox do |v|
    host = RbConfig::CONFIG['host_os']

    # Give VM 1/4 system memory & access to all cpu cores on the host
    if host =~ /darwin/
      cpus = `sysctl -n hw.ncpu`.to_i
      # sysctl returns Bytes and we need to convert to MB
      mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 4
    elsif host =~ /linux/
      cpus = `nproc`.to_i
      # meminfo shows KB and we need to convert to MB
      mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4
    else # sorry Windows folks
      cpus = 2
      mem = 1024
    end

    v.customize ["modifyvm", :id, "--memory", mem]
    v.customize ["modifyvm", :id, "--cpus", cpus]    
    v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
  end

  # Forward ssh agent
  config.ssh.forward_agent = true

  # Set the box were using
  config.vm.box = 'ubuntu/trusty64'

  # Set hostname
  config.vm.hostname = HOSTNAME

  # Private network ip
  config.vm.network :private_network, ip: '192.168.66.6'
  
  # Forward Mariadb port
  config.vm.network "forwarded_port", guest: 3306, host: 33060

  # Add custom hosts
  if defined? VagrantPlugins::HostsUpdater
    hosts = []
    file = '.isodev/hosts'

    if File.exists?(file)
      IO.read(file).split('\n').each do |host|
        if host[0..0] != '#'
          hosts << host
        end
      end
    end

    config.hostsupdater.aliases = hosts
  end

  # Provision
  config.vm.provision :shell, :path => '.isodev/bootstrap.sh'

  # Set synced folder
  config.vm.synced_folder '.', '/vagrant', type: "nfs", mount_options: ['rw', 'vers=3', 'tcp', 'fsc' ,'actimeo=2']
end
