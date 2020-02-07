#!/usr/bin/env bash

set -e

interface="${KEEPALIVED_INTERFACE:-"eth0"}"
password="${KEEPALIVED_PASSWORD:-"d0cker"}"
priority="${KEEPALIVED_PRIORITY:-"150"}"
router_id="${KEEPALIVED_ROUTER_ID:-"51"}"
unicast_peers="${KEEPALIVED_UNICAST_PEERS:-"192.168.1.10,192.168.1.11"}"
virtual_ips="${KEEPALIVED_VIRTUAL_IPS:-"192.168.1.231,192.168.1.232"}"
notify="${KEEPALIVED_NOTIFY:-"/notify.sh"}"

config_file="/etc/keepalived/keepalived.alternative.conf"
if [[ ! -f ${config_file} ]]; then
    echo "configure keepalived: ${config_file}"

    echo -e "\n---- input values ----"
    echo "interface: ${interface}"
    echo "password: ${password}"
    echo "priority: ${priority}"
    echo "router_id: ${router_id}"
    echo "unicast_peers: ${unicast_peers}"
    echo "virtual_ips: ${virtual_ips}"
    echo "notify: ${notify}"
    echo -e "---- input values ----\n"

    mv /keepalived.alternative.conf /etc/keepalived/keepalived.alternative.conf
    sed -i "s|{{ KEEPALIVED_ROUTER_ID }}|$router_id|g" /etc/keepalived/keepalived.alternative.conf
    sed -i "s|{{ KEEPALIVED_INTERFACE }}|$interface|g" /etc/keepalived/keepalived.alternative.conf
    sed -i "s|{{ KEEPALIVED_PRIORITY }}|$priority|g" /etc/keepalived/keepalived.alternative.conf
    sed -i "s|{{ KEEPALIVED_PASSWORD }}|$password|g" /etc/keepalived/keepalived.alternative.conf

    if [[ -n "$notify" ]]; then
        sed -i "s|{{ KEEPALIVED_NOTIFY }}|notify \"$notify\"|g" /etc/keepalived/keepalived.alternative.conf
        chmod +x ${notify}
    else
        sed -i "/{{ KEEPALIVED_NOTIFY }}/d" /etc/keepalived/keepalived.alternative.conf
    fi

    # unicast peers
    for peer in ${unicast_peers//,/ }
    do
        sed -i "s|{{ KEEPALIVED_UNICAST_PEERS }}|${peer}\n    {{ KEEPALIVED_UNICAST_PEERS }}|g" /etc/keepalived/keepalived.alternative.conf
    done
    sed -i "/{{ KEEPALIVED_UNICAST_PEERS }}/d" /etc/keepalived/keepalived.alternative.conf

    # virtual ips
    for vip in ${virtual_ips//,/ }
    do
        sed -i "s|{{ KEEPALIVED_VIRTUAL_IPS }}|${vip}\n    {{ KEEPALIVED_VIRTUAL_IPS }}|g" /etc/keepalived/keepalived.alternative.conf
    done
    sed -i "/{{ KEEPALIVED_VIRTUAL_IPS }}/d" /etc/keepalived/keepalived.alternative.conf
fi

# try to delete virtual ips from interface
for vip in ${virtual_ips//,/ }
do
    IP=${vip}
    IP_INFO=$(ip addr list | grep ${IP}) || continue
    IP_V6=$(echo "${IP_INFO}" | grep "inet6") || true
    # ipv4
    if [[ -z "${IP_V6}" ]]; then
        IP_INTERFACE=$(echo "${IP_INFO}" |  awk '{print $5}')
    # ipv6
    else
        echo "skipping address: ${IP} - ipv6 not supported yet :("
        continue
    fi

    ip addr del ${IP} dev ${IP_INTERFACE} || true
done

echo "start keepalived"

exec keepalived --dont-fork "$@"
