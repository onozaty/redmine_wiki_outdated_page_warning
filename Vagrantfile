Vagrant.configure("2") do |config|
  config.vm.box = "onozaty/redmine-5.0"

  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.synced_folder ".", "/var/lib/redmine/plugins/redmine_wiki_outdated_page_warning", create: true, mount_options: ['dmode=755','fmode=655']

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 2
    vb.memory = "1024"
  end
end
