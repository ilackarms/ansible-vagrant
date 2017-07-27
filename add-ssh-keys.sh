#!/bin/bash
ssh-add -D
for i in $(ls vagrant/.vagrant/machines); do ssh-add vagrant/.vagrant/machines/$i/virtualbox/private_key ; done
for i in $(cat ips); do ssh-keyscan $i >> ~/.ssh/known_hosts; done
