# ImmortalWrt Docker Image for Raspberry Pi 4 Bypass Router
# Based on ImmortalWrt 24.10.5 rootfs

FROM scratch

# Add ImmortalWrt rootfs (armv8 generic for ARM64/Docker)
ADD https://downloads.immortalwrt.org/releases/24.10.5/targets/armsr/armv8/immortalwrt-24.10.5-armsr-armv8-rootfs.tar.gz /

# Set environment
ENV TZ=Asia/Shanghai

# Configure package repositories for aarch64_generic
RUN sed -i 's/snapshots/releases\/24.10.5/g' /etc/opkg/distfeeds.conf 2>/dev/null || true && \
    sed -i 's/ARCH/aarch64_generic/g' /etc/opkg/distfeeds.conf 2>/dev/null || true

# Install required packages
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
    --force-overwrite || true

# Copy custom configuration files
COPY files/ /

# Expose ports
EXPOSE 80 443 22

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget -q --spider http://127.0.0.1 || exit 1

# Start init system
CMD ["/sbin/init"]
