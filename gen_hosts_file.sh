#!/bin/bash

get_ip() {
    SSHCONFIG=$(vagrant ssh-config $1)
    local ip=$(echo $SSHCONFIG | sed -r 's/.*([0-9][0-9][0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*/\1/')
    echo ${ip}
}

cd vagrant && \
echo [master] && \
get_ip master && \
echo "" &&
echo [slaves] && \
slaves=$(cat vms.yml | python /usr/lib/python2.7/site-packages/yq/__main__.py .slaves) && \
for i in $(seq 1 ${slaves}); do
    get_ip slave$i
done && \
cd ..
