# Mattermost Ansible Setup/Upgrade

## Problem

Setting up a Mattermost server is cumbersome so you want to automate it with Ansible

## Solution

Automate the deployment of your Mattermost servers with Ansible. This code is included in `ansible/roles/mattermost`. The file `group_vars/mattermost.yml` holds the configuration variables.

## To Do

1. Get HAProxy configuration working
2. Handle Mattermost upgrade