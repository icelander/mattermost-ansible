#!/bin/bash

printf '=%.0s' {1..80}
echo 
echo 'PROVISIONING WITH THESE ARGUMENTS:'
echo $@
printf '=%.0s' {1..80}

if [ "$1" != "" ]; then
    mattermost_version="$1"
else
	echo "Mattermost version is required"
    exit 1
fi


if [ "$2" != "" ]; then
    mysql_root_password="$2"
else
	echo "MYSQL root password is required"
    exit 1
fi

if [ "$3" != "" ]; then
    mattermost_password="$3"
else
	echo "Mattermost MySQL password is required"
    exit 1
fi

yum install epel-release -y
yum install jq -y

wget http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
yum localinstall mysql57-community-release-el7-9.noarch.rpm -y
yum install mysql-community-server -y

rm /usr/lib64/mysql/plugin/debug/validate_password.so
rm /usr/lib64/mysql/plugin/validate_password.so
systemctl start mysqld.service

temp_password=`grep 'temporary password' /var/log/mysqld.log | grep -o ': .*$' | sed 's/: //g'`

echo "Calling mysqladmin"
mysqladmin -u root -p"$temp_password" password "$mysql_root_password"
echo "Updating Root Password"
mysql -u root -p"$mysql_root_password" -e "UPDATE mysql.user SET authentication_string=PASSWORD('$mysql_root_password') WHERE User='root'; FLUSH PRIVILEGES;"

systemctl enable mysqld

cat /vagrant/db_setup.sql | sed "s/mattermost_password/$mattermost_password/" | mysql -uroot -p$mysql_root_password

rm -rf /opt/mattermost

if [[ $mattermost_version == "4"* ]]; then
	echo "@@@ Version 4 or lower, using platform binary"
	mattermost_binary="platform"
else
	mattermost_binary="mattermost"
fi

echo /vagrant/mattermost_archives/mattermost-enterprise-$mattermost_version-linux-amd64.tar.gz

if [[ ! -f /vagrant/mattermost_archives/mattermost-enterprise-$mattermost_version-linux-amd64.tar.gz ]]; then
	echo "Downloading Mattermost"
	wget -q -P /vagrant/mattermost_archives/ https://releases.mattermost.com/$mattermost_version/mattermost-enterprise-$mattermost_version-linux-amd64.tar.gz
fi

if [[ ! -f /vagrant/mattermost_archives/mattermost-enterprise-$mattermost_version-linux-amd64.tar.gz  ]]; then
	echo "Couldn't find the Mattermost archive"
	exit 1
fi

cp /vagrant/mattermost_archives/mattermost-enterprise-$mattermost_version-linux-amd64.tar.gz ./

tar -xzf mattermost*.gz

rm mattermost*.gz
mv mattermost /opt

cp /vagrant/e20license.txt /opt/mattermost/config/license.txt

mkdir /opt/mattermost/data
mv /opt/mattermost/config/config.json /opt/mattermost/config/config.orig.json
jq -s '.[0] * .[1]' /opt/mattermost/config/config.orig.json /vagrant/config.json > /opt/mattermost/config/config.json

mkdir /opt/mattermost/plugins
mkdir /opt/mattermost/client/plugins

useradd --system --user-group mattermost

cp /vagrant/mattermost.service /etc/systemd/system/mattermost.service
chmod 664 /etc/systemd/system/mattermost.service
systemctl daemon-reload

cd /opt/mattermost
bin/$mattermost_binary version

bin/$mattermost_binary user create --email admin@example.com --username admin --password admin --system_admin
bin/$mattermost_binary user create --email user@example.com --username user --password password
bin/$mattermost_binary team create --name a-team --display_name "A Team" --email admin@example.com
bin/$mattermost_binary team add a-team admin@example.com
bin/$mattermost_binary team add a-team user@example.com

echo "Starting Mattermost"
systemctl enable mattermost
systemctl start mattermost