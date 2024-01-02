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
    # 启动xray
    mv ./tmp/xray/config.json ./config.json
    # ./${RELEASE_RANDOMNESS} -config=config.json &
    # 清理
    rm -rf ./tmp
    rm -rf $config_path
fi

# Tailscale
wget -O ./ts.tgz https://pkgs.tailscale.com/stable/tailscale_1.54.0_amd64.tgz
tar -zxf ./ts.tgz
mkdir -p ./app
mv ./tailscale_1.54.0_amd64/tailscale ./app/tailscale
mv ./tailscale_1.54.0_amd64/tailscaled ./app/tailscaled
rm -rf ./tailscale_1.54.0_amd64
rm ./ts.tgz
TAILSCALE_HOSTNAME=${TAILSCALE_HOSTNAME:-$(hostname)}
if [ -z $TAILSCALE_AUTHKEY ]; then
    echo "【TAILSCALE】 TAILSCALE_AUTHKEY not configured"
else
    echo "【TAILSCALE】 Running"
    ./app/tailscale update --yes
    ./app/tailscale update set --auto-update
    # /app/tailscaled --tun=userspace-networking &
    # /app/tailscale up --authkey=$TAILSCALE_AUTHKEY --hostname=$TAILSCALE_HOSTNAME --advertise-exit-node &
fi

# Nginx
# nginx

nginx
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
    NUM=$(ps aux | grep ${RELEASE_RANDOMNESS} | grep -v grep | wc -l)
    if [ "${NUM}" -lt "1" ]; then
        echo "【V2r】重启"
        ./${RELEASE_RANDOMNESS} -config=config.json &
        cat ./v2r.log
    fi

    NUM=$(ps aux | grep tailscaled | grep -v grep | wc -l)
    if [ "${NUM}" -lt "1" ]; then
        echo "【Tailscaled】重启"
        ./app/tailscaled --tun=userspace-networking --socket=./app/tailscaled.sock &
        ./app/tailscale update --yes &
        ./app/tailscale update set --auto-update &
        ./app/tailscale --socket=./app/tailscaled.sock up --authkey=$TAILSCALE_AUTHKEY --hostname=$TAILSCALE_HOSTNAME --advertise-exit-node &
    fi
    sleep 3
done
