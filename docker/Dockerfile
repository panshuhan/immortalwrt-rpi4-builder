# ImmortalWrt Docker Image for Raspberry Pi 4 Bypass Router
# Based on OpenWrt official Docker image with ImmortalWrt packages

FROM openwrt/rootfs:aarch64-openwrt-23.05

# Set environment
ENV TZ=Asia/Shanghai

# Add ImmortalWrt package feeds
RUN echo "src/gz immortalwrt_core https://downloads.immortalwrt.org/releases/24.10.5/targets/armsr/armv8/packages" >> /etc/opkg/distfeeds.conf && \
    echo "src/gz immortalwrt_base https://downloads.immortalwrt.org/releases/24.10.5/packages/aarch64_generic/base" >> /etc/opkg/distfeeds.conf && \
    echo "src/gz immortalwrt_luci https://downloads.immortalwrt.org/releases/24.10.5/packages/aarch64_generic/luci" >> /etc/opkg/distfeeds.conf && \
    echo "src/gz immortalwrt_packages https://downloads.immortalwrt.org/releases/24.10.5/packages/aarch64_generic/packages" >> /etc/opkg/distfeeds.conf && \
    echo "src/gz immortalwrt_routing https://downloads.immortalwrt.org/releases/24.10.5/packages/aarch64_generic/routing" >> /etc/opkg/distfeeds.conf

# Update and install packages
RUN opkg update && \
    opkg install \
    luci-ssl \
    luci-app-passwall \
    luci-i18n-passwall-zh-cn \
    luci-app-openclash \
    luci-app-ddns \
    luci-i18n-ddns-zh-cn \
    luci-app-upnp \
    luci-i18n-upnp-zh-cn \
    luci-app-vsftpd \
    luci-i18n-vsftpd-zh-cn \
    luci-app-samba4 \
    luci-i18n-samba4-zh-cn \
    luci-app-ttyd \
    luci-i18n-ttyd-zh-cn \
    --force-overwrite || true && \
    rm -rf /tmp/opkg-lists/*

# Copy custom configuration files
COPY files/ /

# Expose ports
EXPOSE 80 443 22

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget -q --spider http://127.0.0.1 || exit 1

# Start init system
CMD ["/sbin/init"]
