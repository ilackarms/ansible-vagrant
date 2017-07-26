#!/bin/bash
for i in $(ls vagrant/.vagrant/machines); do ssh-add vagrant/.vagrant/machines/$i/virtualbox/private_key ; done
