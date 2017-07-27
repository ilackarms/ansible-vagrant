#!/bin/bash

IPS=../ips
TMPHOSTSFILE=tmphostsfile

# for livbvirt
get_ip() {
    local SSHCONFIG=$(vagrant ssh-config $1)
    local ip=$(echo $SSHCONFIG | sed -r 's/.*([0-9][0-9][0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*/\1/')
    echo ${ip}
}

# for virtualbox
get_ip_via_ssh() {
	local ipinfo=$(vagrant ssh $1 -- /usr/sbin/ip addr | grep inet | grep 172.31) #192.168)
    local ip=$(echo $ipinfo | sed -r 's/.*([0-9][0-9][0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\/.*/\1/')
    echo ${ip}
}

cd vagrant && \
cat > ${TMPHOSTSFILE} <<EOF
[OSEv3:children]
masters
nodes
etcd

[OSEv3:vars]
ansible_ssh_user=vagrant
deployment_type=origin

[masters]
EOF
host=$(get_ip_via_ssh master)
echo $host >> ${TMPHOSTSFILE}
echo $host > ${IPS}
echo "" >> ${TMPHOSTSFILE}
echo [nodes] >> ${TMPHOSTSFILE}
nodes=$(cat cluster.yml | python /usr/lib/python2.7/site-packages/yq/__main__.py .nodes) && \
for i in $(seq 1 ${nodes}); do
    host=$(get_ip_via_ssh node${i})
    echo $host >> ${TMPHOSTSFILE}
    echo $host >> ${IPS}
done && \
echo "" >> ${TMPHOSTSFILE}
echo [etcd] >> ${TMPHOSTSFILE}
host=$(get_ip_via_ssh etcd)
echo $host >> ${TMPHOSTSFILE}
echo $host >> ${IPS}
cat ${TMPHOSTSFILE} && \
rm ${TMPHOSTSFILE} && \
cd ..
