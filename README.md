# ImmortalWrt Builder for Raspberry Pi 4

Automated GitHub Actions workflow to build ImmortalWrt firmware for Raspberry Pi 4 with pre-configured proxy tools and utilities.

## Features

- **Automated Building**: GitHub Actions workflow for hands-free builds
- **Proxy Tools**: Passwall, OpenClash, SSR Plus+ pre-installed
- **Ad Blocking**: AdGuard Home included
- **System Utilities**: DDNS, UPnP, Samba, FTP, Web Terminal
- **Chinese Language**: Full Chinese language support
- **Customizable**: Easy configuration through simple text files

## Quick Start

### 1. Fork This Repository

Click the "Fork" button at the top right of this page.

### 2. Customize Configuration (Optional)

Edit the following files to customize your build:

- **`config/packages.list`**: Add or remove packages
- **`config/custom-files/etc/config/network`**: Change default IP (default: 192.168.1.1)
- **`config/custom-files/etc/config/system`**: Change hostname and timezone

### 3. Trigger Build

1. Go to the **Actions** tab in your forked repository
2. Click on **Build ImmortalWrt for Raspberry Pi 4**
3. Click **Run workflow**
4. (Optional) Change ImmortalWrt version (default: 24.10.5)
5. Click **Run workflow** button

### 4. Download Firmware

1. Wait 20-35 minutes for the build to complete
2. Go to the **Releases** page
3. Download the latest release
4. Verify with SHA256: `sha256sum -c sha256sums.txt`

## Installation

### Flash to SD Card

**Linux/macOS:**
```bash
# Decompress
gunzip immortalwrt-*.img.gz

# Flash to SD card (replace /dev/sdX with your SD card)
sudo dd if=immortalwrt-*.img of=/dev/sdX bs=4M status=progress
sync
```

**Windows:**
Use [balenaEtcher](https://www.balena.io/etcher/) or [Rufus](https://rufus.ie/)

### First Boot

1. Insert SD card into Raspberry Pi 4
2. Connect Ethernet cable
3. Power on
4. Access web interface: http://192.168.1.1
5. Default: No password (set one immediately!)

## Configuration Files

### Package List (`config/packages.list`)

Add or remove packages:
```
# Add a package
luci-app-example

# Remove a package (comment out)
# luci-app-unwanted
```

### Network Settings (`config/custom-files/etc/config/network`)

Change default LAN IP:
```
config interface 'lan'
    option ipaddr '192.168.10.1'  # Change this
    option netmask '255.255.255.0'
```

### System Settings (`config/custom-files/etc/config/system`)

Change hostname and timezone:
```
config system
    option hostname 'MyRouter'          # Change hostname
    option zonename 'Asia/Shanghai'     # Change timezone
```

## Build Details

### Workflow Steps

1. **Prepare ImageBuilder**: Download official ImmortalWrt ImageBuilder
2. **Add Repositories**: Add kenzok8 third-party repository
3. **Customize Settings**: Apply custom configurations
4. **Build Firmware**: Compile firmware with selected packages
5. **Create Release**: Upload to GitHub Releases

### Build Time

- Download ImageBuilder: 1-2 minutes
- Update package index: 2-3 minutes
- Download packages: 10-15 minutes
- Build firmware: 5-10 minutes
- Upload: 2-3 minutes
- **Total: 20-35 minutes**

### Target Specifications

- **Device**: Raspberry Pi 4 (all RAM variants)
- **Target**: bcm27xx/bcm2711
- **Architecture**: aarch64_cortex-a72
- **ImmortalWrt Version**: 24.10.5 (default)

## Included Packages

### Proxy Tools
- luci-app-passwall
- luci-app-openclash
- luci-app-ssr-plus
- Chinese language packs

### Utilities
- luci-app-adguardhome (Ad blocking)
- luci-app-ddns (Dynamic DNS)
- luci-app-upnp (UPnP support)
- luci-app-vsftpd (FTP server)
- luci-app-samba4 (File sharing)
- luci-app-ttyd (Web terminal)

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── build-immortalwrt.yml    # GitHub Actions workflow
├── config/
│   ├── custom-repositories.conf     # Third-party repositories
│   ├── packages.list                # Packages to install
│   └── custom-files/                # Files copied to firmware
│       └── etc/config/              # System configurations
├── scripts/
│   ├── prepare-imagebuilder.sh      # Download ImageBuilder
│   ├── add-custom-repos.sh          # Add custom repositories
│   └── customize-firmware.sh        # Customize settings
└── README.md                        # This file
```

## Troubleshooting

### Build Failed

1. Check the Actions log for error messages
2. Common issues:
   - Package not found: Check package name in `config/packages.list`
   - Network error: Re-run the workflow
   - Repository unavailable: Wait and try again

### Cannot Access Router

1. Check LAN connection
2. Verify IP address (default: 192.168.1.1)
3. Try different browser
4. Reset router (hold reset button 10 seconds)

### WiFi Not Working

WiFi is disabled by default for security:
1. Log into web interface (http://192.168.1.1)
2. Go to Network → Wireless
3. Enable radio and configure SSID/password
4. Click Save & Apply

## Security Notes

- **Change default password immediately** after first login
- **Update firmware regularly** for security patches
- **Disable unused services** to reduce attack surface
- **Use strong WiFi passwords** (WPA2/WPA3)

## Advanced Usage

### Build Different Version

In workflow trigger, change `immortalwrt_version` to desired version:
- 24.10.5 (default, latest stable)
- 24.10.4
- Check [ImmortalWrt Releases](https://downloads.immortalwrt.org/releases/) for available versions

### Add Custom Packages

1. Edit `config/packages.list`
2. Add package name (one per line)
3. Commit and push
4. Run workflow

### Modify Build Scripts

Scripts are in `scripts/` directory:
- `prepare-imagebuilder.sh`: Modify download logic
- `add-custom-repos.sh`: Add more repositories
- `customize-firmware.sh`: Advanced customization

## Credits

- **ImmortalWrt**: https://github.com/immortalwrt/immortalwrt
- **kenzok8**: https://github.com/kenzok8/openwrt-packages
- **OpenWrt**: https://openwrt.org/

## License

This project is released under the MIT License.

## Support

- **ImmortalWrt Issues**: https://github.com/immortalwrt/immortalwrt/issues
- **This Builder**: Open an issue in this repository

## Changelog

### 2026-04-05
- Initial release
- ImmortalWrt 24.10.5 support
- Raspberry Pi 4 target
- Automated GitHub Actions workflow
- Pre-configured proxy tools and utilities
