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
	local ipinfo=$(vagrant ssh $1 -- /usr/sbin/ip addr | grep inet | grep 192.168)
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
ansible_become=true
deployment_type=origin
openshift_disable_check=disk_availability,memory_availability,docker_storage,package_version

[masters]
EOF
host=$(get_ip_via_ssh master)
echo "${host} openshift_schedulable=true openshift_ip=${host} openshift_public_ip=${host} openshift_public_hostname=${host} openshift_hostname=${host}" >> ${TMPHOSTSFILE}
echo $host > ${IPS}
echo "" >> ${TMPHOSTSFILE}
echo [etcd] >> ${TMPHOSTSFILE}
echo "${host} openshift_schedulable=true openshift_ip=${host} openshift_public_ip=${host} openshift_public_hostname=${host} openshift_hostname=${host}" >> ${TMPHOSTSFILE}
echo "" >> ${TMPHOSTSFILE}
echo [nodes] >> ${TMPHOSTSFILE}
host=$(get_ip_via_ssh master)
echo "${host} openshift_schedulable=true openshift_ip=${host} openshift_public_ip=${host} openshift_public_hostname=${host} openshift_hostname=${host} openshift_node_labels=\"{'region': 'infra'}\" " >> ${TMPHOSTSFILE}
nodes=$(cat cluster.yml | python /usr/lib/python2.7/site-packages/yq/__main__.py .nodes)
for i in $(seq 1 ${nodes}); do
    host=$(get_ip_via_ssh node${i})
    echo "${host} openshift_schedulable=true openshift_ip=${host} openshift_public_ip=${host} openshift_public_hostname=${host} openshift_hostname=${host} openshift_node_labels=\"{'region': 'infra'}\" " >> ${TMPHOSTSFILE}
    echo $host >> ${IPS}
done
cat ${TMPHOSTSFILE}
rm ${TMPHOSTSFILE}
cd ..
