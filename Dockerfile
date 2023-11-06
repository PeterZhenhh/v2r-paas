FROM nginx:latest
ENV TZ=Asia/Shanghai
USER root
# RUN apt install -y ca-certificates bash curl
COPY nginx/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/static-html /usr/share/nginx/html/index
COPY nginx/h5-speedtest /usr/share/nginx/html/speedtest
COPY configure.sh /configure.sh
COPY v2ray_config /
RUN apt-get update && apt-get install -y wget unzip iproute2 systemctl && \
    chmod +x /configure.sh
    
# tailscale
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscaled /app/tailscaled
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscale /app/tailscale
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

ENTRYPOINT ["sh", "/configure.sh"]
