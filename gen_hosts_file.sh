#!/bin/bash

# for livbvirt
get_ip() {
    local SSHCONFIG=$(vagrant ssh-config $1)
    local ip=$(echo $SSHCONFIG | sed -r 's/.*([0-9][0-9][0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*/\1/')
    echo ${ip}
}

# for virtualbox
get_ip_via_ssh() {
    local ipinfo=$(vagrant ssh $1 -- /usr/sbin/ip addr | grep inet | grep 192.168)
    local ip=$(echo $ipinfo | sed -r 's/.*([0-9][0-9][0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\/.*/\1/')
    echo ${ip}
}

cd vagrant && \
echo [master] && \
get_ip_via_ssh master && \
echo "" &&
echo [slaves] && \
slaves=$(cat vms.yml | python /usr/lib/python2.7/site-packages/yq/__main__.py .slaves) && \
for i in $(seq 1 ${slaves}); do
    get_ip_via_ssh slave$i
done && \
cd ..
