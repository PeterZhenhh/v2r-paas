#!/bin/sh
# XRay generate configuration
# Download and install XRay
config_path="ws_tls.json"
mkdir /tmp/xray
curl -L -H "Cache-Control: no-cache" -o /tmp/xray/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip /tmp/xray/xray.zip -d /tmp/xray
rm /tmp/xray/geoip.dat
rm /tmp/xray/geosite.dat
curl -L -H "Cache-Control: no-cache" -o /tmp/xray/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
curl -L -H "Cache-Control: no-cache" -o /tmp/xray/geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
install -m 755 /tmp/xray/xray /usr/local/bin/xray
install -m 755 /tmp/xray/geosite.dat /usr/local/bin/geosite.dat
install -m 755 /tmp/xray/geoip.dat /usr/local/bin/geoip.dat
xray -version
# Remove temporary directory
rm -rf /tmp/xray
# XRay new configuration
install -d /usr/local/etc/xray
envsubst '\$UUID,\$CFKEY,\$CFV6,\$CFR1,\$CFR2,\$CFR3,\$WS_PATH' < $config_path > /usr/local/etc/xray/config.json
# MK TEST FILES
mkdir /opt/test
cd /opt/test
dd if=/dev/zero of=100mb.bin bs=100M count=1
dd if=/dev/zero of=10mb.bin bs=10M count=1
# Run XRay
/usr/local/bin/xray -config /usr/local/etc/xray/config.json &
# Run nginx
sh -c "envsubst '\$PORT,\$UUID,\$WS_PATH' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'
