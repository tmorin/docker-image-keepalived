[![Build Status](https://travis-ci.org/tmorin/docker-image-keepalived.svg)](https://travis-ci.org/tmorin/docker-image-keepalived)

# docker-image-keepalived

Provide a Docker image running [keepalived](https://keepalived.org/) which is highly inspired by the project [osixia/docker-keepalived](https://github.com/osixia/docker-keepalived).

## Configuration

- `KEEPALIVED_INTERFACE`: Keepalived network interface. Default value `eth0`
- `KEEPALIVED_PASSWORD`:  Keepalived password. Default value `d0cker`
- `KEEPALIVED_PRIORITY`:  Keepalived node priority. Default value `150`
- `KEEPALIVED_ROUTER_ID`:  Keepalived virtual router ID. Default value `51`
- `KEEPALIVED_UNICAST_PEERS`:  Keepalived unicast peers. Default value `192.168.1.10,192.168.1.11`
- `KEEPALIVED_VIRTUAL_IPS`:  Keepalived virtual IPs. Default value `192.168.1.231,192.168.1.232`
- `KEEPALIVED_NOTIFY`:  Script to execute when node state change. Default value `/notify.sh`

## Usage

```bash
docker run -d --name keepalived --restart=always \
    --cap-add=NET_ADMIN --net=host \
    -e KEEPALIVED_VIRTUAL_IPS="192.168.0.99" \
    -e KEEPALIVED_UNICAST_PEERS="192.168.0.100,192.168.0.101,192.168.0.102" \
    thibaultmorin/keepalived
```
