# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

CONFIG = File.join(File.dirname(__FILE__), "config.rb")

# Default config
$hostname = "isodev"
$vm_memory = 1024
$vm_cpus = 1
$share_home = false
$shared_folders = {}

if File.exist?(CONFIG)
  require CONFIG
end

Vagrant.configure("2") do |config|
  # always use Vagrants insecure key
  config.ssh.insert_key = false

  # Set the box were using
  config.vm.box = 'ubuntu/trusty64'

  # Virtualbox configuration
  config.vm.provider :virtualbox do |v|
    v.check_guest_additions = false
    v.functional_vboxsf     = false
    v.gui                   = $vm_gui
    v.memory                = $vm_memory
    v.cpus                  = $vm_cpus
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  # Parallels configuration
  config.vm.provider "parallels" do |v, override|
    override.vm.box = "parallels/ubuntu-14.04"
    v.check_guest_tools          = true
    v.optimize_power_consumption = false
    v.memory                     = $vm_memory
    v.cpus                       = $vm_cpus
  end

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  # Forward ssh agent
  config.ssh.forward_agent = true

  # Set hostname
  config.vm.hostname = $hostname

  # Private network ip
  config.vm.network :private_network, ip: "10.37.129.3"

  # Forward Mariadb port
  config.vm.network "forwarded_port", guest: 3306, host: 33060

  # Forward Mailhog port
  config.vm.network "forwarded_port", guest: 8025, host: 8025

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
  $shared_folders.each_with_index do |(host_folder, guest_folder), index|
    config.vm.synced_folder host_folder.to_s, guest_folder.to_s, id: "isodev-share%02d" % index, nfs: true, mount_options: ['nolock,vers=3,udp']
  end
end
