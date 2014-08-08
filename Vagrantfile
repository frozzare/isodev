# -*- mode: ruby -*-
# vi: set ft=ruby :

# The hostname to use
HOSTNAME = 'iso.dev'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Virtualbox configuration
  config.vm.provider :virtualbox do |v|
    v.customize ['modifyvm', :id, '--memory', 1024]
    v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
  end

  # Forward ssh agent
  config.ssh.forward_agent = true

  # Set the box were using
  config.vm.box = 'ubuntu/trusty64'

  # Set hostname
  config.vm.hostname = HOSTNAME

  # Add custom hosts
  if defined? VagrantPlugins::HostsUpdater
    hosts = []
    file = '.isodev/hosts'

    if File.exists?(file)
      IO.read(file).split("\n").each do |host|
        if host[0..0] != '#'
          hosts << host
        end
      end
    end

    config.hostsupdater.aliases = hosts
  end

  # Private network ip
  config.vm.network :private_network, ip: '192.168.66.6'

  # Provision
  config.vm.provision :shell, :path => '.isodev/bootstrap.sh'

  # Set synced folder
  config.vm.synced_folder '.', '/vagrant', :nfs => true, :mount_options => ['nolock,vers=3,udp']
end