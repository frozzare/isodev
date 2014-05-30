# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|

  config.vm.provider :virtualbox do |v|
    v.customize ['modifyvm', :id, '--memory', 1024]
    v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
  end

  config.ssh.forward_agent = true
  config.vm.box = 'ubuntu/trusty64'
  config.vm.hostname = 'iso.dev'

  # Add custom hosts.
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

  config.vm.network :private_network, ip: '192.168.66.6'

  config.vm.provision :shell, :path => '.isodev/bootstrap.sh'

  config.vm.synced_folder '.', '/vagrant', :nfs => true
end