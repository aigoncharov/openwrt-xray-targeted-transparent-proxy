#!/bin/sh

opkg remove xray-core
opkg remove v2fly-geoip v2fly-geosite
opkg remove python3
opkg remove iptables-mod-conntrack-extra \
  iptables-mod-extra \
  iptables-mod-filter \
  iptables-mod-tproxy \
  kmod-ipt-nat6 

rm -f /etc/xray/vless_subscription_url
rm -f /etc/xray/config.json
rm -f /etc/config/xray

echo "" > /etc/firewall.xraytproxy

/etc/init.d/firewall restart
