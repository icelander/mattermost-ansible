MATTERMOST_VERSION = '5.22.3'

MYSQL_ROOT_PASSWORD = 'mysql_root_passowrd'
MATTERMOST_PASSWORD = 'really_secure_password'

Vagrant.configure("2") do |config|
	config.vm.box = "bento/centos-7"

	config.vm.define 'mattermost' do |box|
		box.vm.hostname = 'mattermost.sncorp.com'
		box.vm.network "forwarded_port", guest: 8065, host: 8065
		box.vm.network "forwarded_port", guest: 3306, host: 13306
		
		box.vm.provision :shell, path: 'mattermost_setup.sh', args: [MATTERMOST_VERSION, MYSQL_ROOT_PASSWORD, MATTERMOST_PASSWORD]
	end
end