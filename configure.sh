#!/bin/sh
curl -sLo warp-reg https://github.com/badafans/warp-reg/releases/download/v1.0/main-linux-amd64 && chmod +x warp-reg && ./warp-reg
# XRay generate configuration
# Download and install XRay
config_path="ws_tls.json"
mkdir ./tmp/xray
curl -L -H "Cache-Control: no-cache" -o ./tmp/xray/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip ./tmp/xray/xray.zip -d ./tmp/xray

# 伪装 xray 执行文件
RELEASE_RANDOMNESS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
mv ./tmp/xray/xray ${RELEASE_RANDOMNESS}
envsubst '\$UUID,\$CFKEY,\$CFV6,\$CFR1,\$CFR2,\$CFR3,\$WS_PATH' <$config_path >./tmp/xray/config.json
envsubst '\$PORT,\$UUID,\$WS_PATH' </etc/nginx/conf.d/default.conf.template >/etc/nginx/conf.d/default.conf
cat ./tmp/xray/config.json | base64 >config
rm -rf ./tmp
rm -rf $config_path
nginx
base64 -d config >./config.json
./${RELEASE_RANDOMNESS} -config=config.json

# tailscale
if ! ${TAILSCALE_HOSTNAME}; then
    TAILSCALE_HOSTNAME=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
fi
if ${TAILSCALE_AUTHKEY}; then
    /app/tailscaled --tun=userspace-networking &
    sleep 5
    /app/tailscale up --authkey=$TAILSCALE_AUTHKEY --hostname=$TAILSCALE_HOSTNAME --advertise-exit-node --accept-routes
fi
