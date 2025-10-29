#!/bin/sh

# Nginx
# 注入环境变量
envsubst '\$PORT,\$UUID,\$WS_PATH' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
# 启动Nginx
nginx

# Xry
if [ -z "$UUID" ]; then
    echo "【XRAY】 UUID未配置"
else
    RELEASE_RANDOMNESS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
    mkdir -p ./${RELEASE_RANDOMNESS}
    # 拷贝预下载的 Xry
    mv /opt/xray/xray ./${RELEASE_RANDOMNESS}/${RELEASE_RANDOMNESS}
    mv /opt/xray/geoip.dat ./${RELEASE_RANDOMNESS}/geoip.dat
    mv /opt/xray/geosite.dat ./${RELEASE_RANDOMNESS}/geosite.dat
    # 注入环境变量
    envsubst '\$UUID,\$CFKEY,\$CFV6,\$CFR1,\$CFR2,\$CFR3,\$WS_PATH' < /v2r_config/ws_tls.json > ./${RELEASE_RANDOMNESS}/config.json
    # 启动Xry
    ./${RELEASE_RANDOMNESS}/${RELEASE_RANDOMNESS} -config=./${RELEASE_RANDOMNESS}/config.json &
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
