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
cat > tmphostsfile <<EOF
[OSEv3:children]
masters
nodes

[OSEv3:vars]
ansible_ssh_user=vagrant
deployment_type=origin

[masters]
EOF
get_ip_via_ssh master >> tmphostsfile && \
echo "" >> tmphostsfile
echo [nodes] >> tmphostsfile
nodes=$(cat cluster.yml | python /usr/lib/python2.7/site-packages/yq/__main__.py .nodes) && \
for i in $(seq 1 ${nodes}); do
    get_ip_via_ssh node$i >> tmphostsfile
done && \
cat tmphostsfile && \
rm tmphostsfile && \
cd ..
