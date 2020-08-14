CREATE DATABASE IF NOT EXISTS mattermost;

CREATE USER 'mmuser'@'%' IDENTIFIED BY 'mattermost_password';
SET PASSWORD FOR mmuser = PASSWORD('mattermost_password');
GRANT ALTER, CREATE, DELETE, DROP, INDEX, INSERT, SELECT, UPDATE ON `mattermost`.* TO 'mmuser'@'%';

FLUSH PRIVILEGES;