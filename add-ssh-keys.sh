#!/bin/bash
for i in $(ls vagrant/.vagrant/machines); do ssh-add vagrant/.vagrant/machines/$i/libvirt/private_key ; done
