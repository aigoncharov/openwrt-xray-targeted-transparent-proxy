#!/bin/sh

# This script outputs a list of IP addresses with associated MAC addresses on OpenWrt

# Get the list of DHCP leases
LEASES_FILE="/tmp/dhcp.leases"

# Check if the leases file exists
if [ ! -f "$LEASES_FILE" ]; then
  echo "DHCP leases file not found!"
  exit 1
fi

echo "Here is the list of IP addresses with associated MAC addresses:"
# Output the list of IP addresses with associated MAC addresses
awk '{print $3, $2}' "$LEASES_FILE"

# Ask user to input a list of selected MAC addresses separated by comma
read -p "Enter a list of selected MAC addresses separated by comma: " mac_addresses

# Convert the input string to an array
if [ -z "$mac_addresses" ]; then
  echo "No MAC addresses entered!"
  exit 1
fi

# Ask user to input the router IP address with a default value
read -p "Enter the router IP address [Default: 192.168.1.1]: " router_ip
router_ip=${router_ip:-192.168.1.1}

echo "Router IP address set to: $router_ip"

# Ask user to input a V2LESS subscription URL
read -p "Enter your V2LESS subscription URL: " v2less_url

# Exit if the URL is empty
if [ -z "$v2less_url" ]; then
  echo "V2LESS subscription URL cannot be empty!"
  exit 1
fi

mkdir -p /etc/xray

echo "V2LESS subscription URL set to: $v2less_url"
echo  "$v2less_url" > /etc/xray/vless_subscription_url

# Fetch the VLESS JSON config from the V2LESS subscription URL using wget
vless_config=$(wget -qO- "$v2less_url")

# Check if the config was fetched successfully
if [ -z "$vless_config" ]; then
  echo "Failed to fetch VLESS config from the subscription URL!"
  exit 1
fi

echo "Installing base64..."
opkg update
opkg install coreutils-base64

# Decode the V2LESS subscription URL from base64
vless_config=$(echo "$vless_config" | base64 -d)

# Check if the URL was decoded successfully
if [ -z "$vless_config" ]; then
  echo "Failed to decode V2LESS config from base64!"
  exit 1
fi

echo "Installing python..."
opkg update
opkg install python3

outbounds=$(python3 v2ray2json.py "$vless_config")
if [ $? -ne 0 ]; then
  echo "Failed to convert VLESS config to JSON!"
  exit 1
fi

cat <<EOF > /etc/xray/config.json
{
  "inbounds": [
    {
      "port": 12345,
      "listen": "127.0.0.1",
      "protocol": "dokodemo-door",
      "settings": {
        "network": "tcp",
        "followRedirect": true
      },
      "streamSettings": {
        "sockopt": {
          "tproxy": "tproxy"
        }
      }
    }
  ],
  "outbounds": $outbounds,
  "dns": {
    "servers": [
      "8.8.8.8"
    ]
  }
}
EOF

echo "VLESS config saved to /etc/xray/config.json"

echo "Installing iptables..."
opkg update
opkg install iptables \
  iptables-mod-conntrack-extra \
  iptables-mod-extra \
  iptables-mod-filter \
  iptables-mod-tproxy \
  kmod-ipt-nat6 

echo "Installing xray-core..."
opkg update
opkg install xray-core

echo "Saving iptables config to /etc/firewall.xraytproxy..."
cat <<EOF > /etc/firewall.xraytproxy
# Flush existing XRAY chain to prevent duplicates
iptables -t mangle -D PREROUTING -p all -j XRAY 2>/dev/null
iptables -t mangle -F XRAY 2>/dev/null
iptables -t mangle -X XRAY 2>/dev/null
iptables -t mangle -N XRAY 2>/dev/null

# Exclude router and localhost traffic from TPROXY
iptables -t mangle -A XRAY -d $router_ip -j RETURN
iptables -t mangle -A XRAY -d 127.0.0.1 -j RETURN

# Apply XRAY chain in PREROUTING
iptables -t mangle -A PREROUTING -j XRAY

# Ensure marked packets are handled locally
ip rule add fwmark 1 table 100
ip route add local default dev lo table 100

# Mark traffic by MAC address
EOF

IFS=","
for mac in $mac_addresses; do
  echo "iptables -t mangle -A XRAY -m mac --mac-source '$mac' -p tcp -j TPROXY --tproxy-mark 1 --on-ip 127.0.0.1 --on-port 12345" >> /etc/firewall.xraytproxy
done

echo "Saving xray config to /etc/config/xray..."
cat <<EOF > /etc/config/xray
config xray 'enabled'
	option enabled '1'

config xray 'config'
	option confdir '/etc/xray'
	list conffiles '/etc/xray/config.json'
	option datadir '/usr/share/xray'
	option dialer ''
	option format 'json'
EOF

if ! grep -q "firewall.xraytproxy" /etc/config/firewall; then
  echo "Updating /etc/config/firewall..."
  cat <<EOF >> /etc/config/firewall
config include
  option	enabled		1
  option	type		'script'
  option	path		'/etc/firewall.xraytproxy'
  option	fw4_compatible	1
EOF
fi

echo "Restarting xray..."
/etc/init.d/xray enable
/etc/init.d/xray start
echo "Restarting firewall..."
/etc/init.d/firewall restart

echo "Done!"
