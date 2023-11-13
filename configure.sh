#!/bin/sh
# Cloudflare Warp
curl -sLo warp-reg https://github.com/badafans/warp-reg/releases/download/v1.0/main-linux-amd64 && chmod +x warp-reg && ./warp-reg

# Xray
if [ -z $UUID ]; then
    echo "【XRAY】 UUID未配置"
else
    config_path="ws_tls.json"
    mkdir -p ./tmp/xray
    # 下载xray
    wget -O ./tmp/xray/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
    unzip ./tmp/xray/xray.zip -d ./tmp/xray
    # 伪装 xray 执行文件
    RELEASE_RANDOMNESS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
    mv ./tmp/xray/xray ${RELEASE_RANDOMNESS}
    envsubst '\$UUID,\$CFKEY,\$CFV6,\$CFR1,\$CFR2,\$CFR3,\$WS_PATH' <$config_path >./tmp/xray/config.json
    envsubst '\$PORT,\$UUID,\$WS_PATH' </etc/nginx/conf.d/default.conf.template >/etc/nginx/conf.d/default.conf
    cat ./tmp/xray/config.json | base64 >config
    # 启动xray
    base64 -d config >./config.json
    ./${RELEASE_RANDOMNESS} -config=config.json &
    # 清理
    rm -rf ./tmp
    rm -rf $config_path
fi

# Tailscale
TAILSCALE_HOSTNAME=${TAILSCALE_HOSTNAME:-$(hostname)}
if [ -z $TAILSCALE_AUTHKEY ]; then
    echo "【TAILSCALE】 TAILSCALE_AUTHKEY not configured"
else
    echo "【TAILSCALE】 Running"
    /app/tailscaled --tun=userspace-networking &
    /app/tailscale up --authkey=$TAILSCALE_AUTHKEY --hostname=$TAILSCALE_HOSTNAME --advertise-exit-node &
fi

# Nginx
nginx

#保持运行
while true; do
    /app/tailscaled --tun=userspace-networking &
    /app/tailscale up --authkey=$TAILSCALE_AUTHKEY --hostname=$TAILSCALE_HOSTNAME --advertise-exit-node &
    ./${RELEASE_RANDOMNESS} -config=config.json &
    sleep 300
done
