#!/bin/sh
curl -sLo warp-reg https://github.com/badafans/warp-reg/releases/download/v1.0/main-linux-amd64 && chmod +x warp-reg && ./warp-reg
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

# 伪装 xray 执行文件
RELEASE_RANDOMNESS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
mv /tmp/xray/xray ${RELEASE_RANDOMNESS}
envsubst '\$UUID,\$CFKEY,\$CFV6,\$CFR1,\$CFR2,\$CFR3,\$WS_PATH' < $config_path > /tmp/xray/config.json
envsubst '\$PORT,\$UUID,\$WS_PATH' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
cat /tmp/xray/config.json | base64 > config
rm -f config.json
wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
nginx
base64 -d config > /tmp/xray/config.json
./${RELEASE_RANDOMNESS} -config=/tmp/xray/config.json

# MK TEST FILES
mkdir /opt/test
cd /opt/test
dd if=/dev/zero of=100mb.bin bs=100M count=1
dd if=/dev/zero of=10mb.bin bs=10M count=1
