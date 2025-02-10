# openwrt-xray-targeted-transparent-proxy

Created a transparent xray proxy only for specific clients (based on MAC addresses) of an OpenWRT router.

1. `wget https://github.com/aigoncharov/openwrt-xray-targeted-transparent-proxy/archive/refs/heads/main.zip -O tmp.zip`
2. `opkg update`
3. `opkg install unzip`
4. `unzip tmp.zip`
5. `rm tmp.zip`
6. `cd openwrt-xray-targeted-transparent-proxy-main`
7. `./install.sh`
8. Follow the instructions and enjoy the results.