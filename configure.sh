#!/bin/sh

# Xray
if [ -z "$UUID" ]; then
    echo "【XRAY】 UUID未配置"
else
    config_path="ws_tls.json"
    mkdir -p /tmp/xray
    RELEASE_RANDOMNESS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)

    # 拷贝预下载的 Xray
    cp /opt/xray/xray /tmp/xray/${RELEASE_RANDOMNESS}
    envsubst '\$UUID,\$CFKEY,\$CFV6,\$CFR1,\$CFR2,\$CFR3,\$WS_PATH' < $config_path > /tmp/xray/config.json
    envsubst '\$PORT,\$UUID,\$WS_PATH' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
    nginx
    mv /tmp/xray/config.json ./config.json
    ./${RELEASE_RANDOMNESS} -config=config.json &
fi

# Tailscale
if [ -z "$TAILSCALE_AUTHKEY" ]; then
    echo "【TAILSCALE】 未配置 AuthKey，跳过启动"
else
    echo "【TAILSCALE】 启动中..."
    mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale
    /opt/tailscale/tailscaled --tun=userspace-networking --socket=/tmp/tailscaled.sock &
    sleep 2
    /opt/tailscale/tailscale --socket=/tmp/tailscaled.sock up \
        --authkey=$TAILSCALE_AUTHKEY \
        --hostname=${TAILSCALE_HOSTNAME:-$(hostname)} \
        --advertise-exit-node &
fi

# 保持运行
while true; do
    sleep 30
done
