#!/bin/sh

# Read the V2LESS subscription URL from the file
v2less_url=$(cat /etc/xray/vless_subscription_url)

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

echo "Restarting xray..."
/etc/init.d/xray restart

echo "Done!"
