# openwrt-xray-targeted-transparent-proxy

Created a transparent xray proxy only for specific clients (based on MAC addresses) of an OpenWRT router. Works with convenient subscription URLs!
It helps you redirect traffic from your dumb devices (think TV) to xray while not affecting the rest of the network.

## Install

1. `wget https://github.com/aigoncharov/openwrt-xray-targeted-transparent-proxy/archive/refs/heads/main.zip -O tmp.zip`
2. `opkg update`
3. `opkg install unzip`
4. `unzip tmp.zip`
5. `rm tmp.zip`
6. `cd openwrt-xray-targeted-transparent-proxy-main`
7. `./install.sh`
8. Follow the instructions and enjoy the results.

## Uninstall

1. `cd openwrt-xray-targeted-transparent-proxy-main`
2. `./uninstall.sh`

## Update config from the subscription URL

1. `cd openwrt-xray-targeted-transparent-proxy-main`
2. `./update.sh`