# openwrt-xray-targeted-transparent-proxy

Create a transparent xray (vray, v2ray, vless) proxy only for specific clients (based on MAC addresses) of an OpenWRT router. Works with convenient subscription URLs!
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

Here is what to expect (roughly):
```
root@OpenWrt:~/openwrt-xray-targeted-transparent-proxy-main# ./install.sh
Here is the list of IP addresses with associated MAC addresses:
192.168.42.13 c8:8a:d8:72:98:37
192.168.42.64 0a:99:e0:ba:2b:f4
192.168.42.146 6c:7e:67:bb:c2:c8
Enter a list of selected MAC addresses separated by comma: c8:8a:d8:72:98:37
Enter the router IP address [Default: 192.168.1.1]: 192.168.42.1
Router IP address set to: 192.168.42.1
Enter your V2LESS subscription URL: https://xxxxxxxxxxxxxxxxxxxxxxxxxxx
V2LESS subscription URL set to: https://xxxxxxxxxxxxxxxxxxxxxxxxxxx
Installing base64...
Installing python...
VLESS config saved to /etc/xray/config.json
Installing iptables...
Installing xray-core...
Saving iptables config to /etc/firewall.xraytproxy...
Saving xray config to /etc/config/xray...
Updating /etc/config/firewall...
Restarting xray...
Restarting firewall...
Done!
```

## Uninstall

1. `cd openwrt-xray-targeted-transparent-proxy-main`
2. `./uninstall.sh`

## Update config from the subscription URL

1. `cd openwrt-xray-targeted-transparent-proxy-main`
2. `./update.sh`
