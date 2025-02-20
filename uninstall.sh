#!/bin/sh

echo "Flushing iptables..."
iptables -t mangle -D PREROUTING -p all -j XRAY 2>/dev/null
iptables -t mangle -F XRAY 2>/dev/null
iptables -t mangle -X XRAY 2>/dev/null

echo "Removing packages..."
opkg remove xray-core
opkg remove v2fly-geoip v2fly-geosite
opkg remove python3
opkg remove iptables-mod-conntrack-extra \
  iptables-mod-extra \
  iptables-mod-filter \
  iptables-mod-tproxy \
  kmod-ipt-nat6 

echo "Removing config..."
rm -f /etc/xray/vless_subscription_url
rm -f /etc/xray/config.json
rm -f /etc/config/xray

echo "" > /etc/firewall.xraytproxy

echo "Restarting firewall..."
/etc/init.d/firewall restart
echo "Restarting network..."
/etc/init.d/network restart
echo "Done!"
