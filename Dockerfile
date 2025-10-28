FROM nginx:latest
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

ENV UUID=$UUID
ENV PORT=$PORT
ENV CFKEY=$CFKEY
ENV CFV6=$CFV6
ENV CFR1=$CFR1
ENV CFR2=$CFR2
ENV CFR3=$CFR3
ENV TAILSCALE_HOSTNAME=$TAILSCALE_HOSTNAME
ENV TAILSCALE_AUTHKEY=$TAILSCALE_AUTHKEY

USER root
# RUN apt install -y ca-certificates bash curl
COPY nginx/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/static-html /usr/share/nginx/html/index
COPY nginx/h5-speedtest /usr/share/nginx/html/speedtest
COPY configure.sh /configure.sh
COPY v2r_config /
    
RUN apt-get update && apt-get install -y wget unzip iproute2 systemctl && chmod +x /configure.sh

# tailscale
# COPY --from=docker.io/tailscale/tailscale:latest /usr/local/bin/tailscaled /app/tailscaled
# COPY --from=docker.io/tailscale/tailscale:latest /usr/local/bin/tailscale /app/tailscale
# RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

# CMD ["sh", "/configure.sh"]
# EXPOSE 80
ENTRYPOINT ["sh", "/configure.sh"]
