#!/bin/sh

# Cloudflare Warp
# curl -sLo warp-reg https://github.com/badafans/warp-reg/releases/download/v1.0/main-linux-amd64 && chmod +x warp-reg && ./warp-reg
# Xray
if [ -z $UUID ]; then
    echo "【XRAY】 UUID未配置"
else
    config_path="ws_tls.json"
    mkdir -p ./tmp/xray
    # 下载xray
    wget -O ./tmp/xray/xray.zip https://ghfast.top/https://github.com/XTLS/Xray-core/releases/download/v25.10.15/Xray-linux-64.zip
    unzip ./tmp/xray/xray.zip -d ./tmp/xray
    # 伪装 xray 执行文件
    RELEASE_RANDOMNESS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
    mv ./tmp/xray/xray ${RELEASE_RANDOMNESS}
    envsubst '\$UUID,\$CFKEY,\$CFV6,\$CFR1,\$CFR2,\$CFR3,\$WS_PATH' <$config_path >./tmp/xray/config.json
    envsubst '\$PORT,\$UUID,\$WS_PATH' </etc/nginx/conf.d/default.conf.template >/etc/nginx/conf.d/default.conf
    nginx
    # 启动xray
    mv ./tmp/xray/config.json ./config.json
    # ./${RELEASE_RANDOMNESS} -config=config.json &
    # 清理
    rm -rf ./tmp
    rm -rf $config_path
fi

# Tailscale
if [ -z $TAILSCALE_AUTHKEY ]; then
    echo "【TAILSCALE】 TAILSCALE_AUTHKEY not configured"
else
    mkdir -p ./app
    wget -O ./ts.tgz https://pkgs.tailscale.com/stable/tailscale_latest_amd64.tgz
    tar -xf ./ts.tgz -C ./app --strip-components=1
    rm ./ts.tgz
    TAILSCALE_HOSTNAME=${TAILSCALE_HOSTNAME:-$(hostname)}
    echo "【TAILSCALE】 Running"
    ./app/tailscaled --tun=userspace-networking --socket=./app/tailscaled.sock &
    ./app/tailscale update --yes &
    ./app/tailscale --socket=./app/tailscaled.sock set --auto-update &
    ./app/tailscale --socket=./app/tailscaled.sock up --authkey=$TAILSCALE_AUTHKEY --hostname=$TAILSCALE_HOSTNAME --advertise-exit-node &
fi

# Nginx
# nginx

# ./${RELEASE_RANDOMNESS} -config=config.json &

#保持运行
# while true; do
#     /app/tailscaled --tun=userspace-networking &
#     /app/tailscale up --authkey=$TAILSCALE_AUTHKEY --hostname=$TAILSCALE_HOSTNAME --advertise-exit-node
#     sleep 300
# done

# ./ts/tailscaled --tun=userspace-networking --socket=./ts/tailscaled.sock &
# ./ts/tailscale --socket=./ts/tailscaled.sock up --authkey=$TAILSCALE_AUTHKEY --hostname=$TAILSCALE_HOSTNAME --advertise-exit-node

while true; do
    # nginx
    if [ ! -z $UUID ]; then
        NUM=$(ps aux | grep ${RELEASE_RANDOMNESS} | grep -v grep | wc -l)
        if [ "${NUM}" -lt "1" ]; then
            echo "【V2r】重启"
            ./${RELEASE_RANDOMNESS} -config=config.json &
            cat ./v2r.log
        fi
    fi
    if [ ! -z $TAILSCALE_AUTHKEY ]; then
        NUM=$(ps aux | grep tailscaled | grep -v grep | wc -l)
        if [ "${NUM}" -lt "1" ]; then
            echo "【Tailscaled】重启"
            ./app/tailscaled --tun=userspace-networking --socket=./app/tailscaled.sock &
            ./app/tailscale update --yes &
            ./app/tailscale --socket=./app/tailscaled.sock set --auto-update &
            ./app/tailscale --socket=./app/tailscaled.sock up --authkey=$TAILSCALE_AUTHKEY --hostname=$TAILSCALE_HOSTNAME --advertise-exit-node &
        fi
    fi
    sleep 3
done
