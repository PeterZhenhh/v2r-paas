FROM nginx:1.27

ARG TZ=Asia/Shanghai
ARG UUID
ARG PORT
ARG CFKEY
ARG CFV6
ARG CFR1
ARG CFR2
ARG CFR3
ARG TAILSCALE_HOSTNAME
ARG TAILSCALE_AUTHKEY

ENV UUID=$UUID \
    PORT=$PORT \
    CFKEY=$CFKEY \
    CFV6=$CFV6 \
    CFR1=$CFR1 \
    CFR2=$CFR2 \
    CFR3=$CFR3 \
    TAILSCALE_HOSTNAME=$TAILSCALE_HOSTNAME \
    TAILSCALE_AUTHKEY=$TAILSCALE_AUTHKEY

USER root

# ✅ 替换 apt 源为阿里云镜像
RUN cp /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bak \
  && sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources \
  && apt-get update \
  && apt-get install -y wget unzip iproute2 systemctl ca-certificates curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# ✅ 拷贝 nginx 模板与资源
COPY nginx/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/static-html /usr/share/nginx/html/index
COPY nginx/h5-speedtest /usr/share/nginx/html/speedtest

# ✅ 拷贝启动脚本和配置模板
COPY configure.sh /configure.sh
COPY v2r_config /v2r_config
RUN chmod +x /configure.sh

# ✅ 预下载并解压 Xray-core
RUN mkdir -p /opt/xray \
    && wget -O /opt/xray/xray.zip https://github.com/XTLS/Xray-core/releases/download/v25.10.15/Xray-linux-64.zip \
    && unzip /opt/xray/xray.zip -d /opt/xray \
    && rm /opt/xray/xray.zip

# ✅ 预下载并解压 Tailscale
RUN mkdir -p /opt/tailscale \
    && wget -O /opt/tailscale/ts.tgz https://pkgs.tailscale.com/stable/tailscale_latest_amd64.tgz \
    && tar -xf /opt/tailscale/ts.tgz -C /opt/tailscale --strip-components=1 \
    && rm /opt/tailscale/ts.tgz

# ✅ 设置可执行权限
RUN chmod +x /opt/xray/xray /opt/tailscale/tailscaled /opt/tailscale/tailscale

# ✅ 设置入口点
ENTRYPOINT ["sh", "/configure.sh"]
