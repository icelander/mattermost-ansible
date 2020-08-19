MATTERMOST_VERSION = '5.22.3'

MYSQL_ROOT_PASSWORD = 'mysql_root_passowrd'
MATTERMOST_PASSWORD = 'really_secure_password'

MATTERMOST_SERVERS = 1

if MATTERMOST_SERVERS > 5
	puts "Maximum Mattermost Servers is 5"
	exit 1
end

Vagrant.configure("2") do |config|
	

	config.vm.define 'main' do |box|
		box.vm.box = "bento/ubuntu-20.04"
		box.vm.hostname = 'mattermost.dst.com'
		box.vm.network "private_network", ip: "192.168.33.99"
		box.vm.network "forwarded_port", guest: 80, host: 8080
		box.vm.network "forwarded_port", guest: 3306, host: 13306
	end

	mattermost_servers = []

	MATTERMOST_SERVERS.times do |i|
		config.vm.define "mattermost#{i}" do |mm|
			mm.vm.box = "centos/7"
			mm.vm.hostname = "mattermost#{i}.mattermost.dst.com"
			mm.vm.network "private_network", ip: "192.168.33.10#{i}"
			mm.vm.network "forwarded_port", guest: 8065, host: "#{i}8065".to_i
		end
		mattermost_servers << "mattermost#{i}"
	end

	config.vm.provision "ansible" do |ansible|
		ansible.playbook = "ansible/playbook.yml"
		ansible.groups = {
			"load_balancer" => ['main'],
			"database" => ["main"],
			"app_server" => mattermost_servers,
			"load_balancer:vars" => { "app_servers" => mattermost_servers }
		}
	end
end