# ImmortalWrt Docker 旁路由

在树莓派 OS 上运行 ImmortalWrt 作为旁路由，用于科学上网。

## 特性

- 🚀 基于 ImmortalWrt 24.10.5
- 🐳 Docker 容器化部署
- 🔧 预配置旁路由模式
- 🌐 包含 Passwall、OpenClash 等代理工具
- 🇨🇳 完整中文支持

## 快速开始

### 方法 1：一键部署（推荐）

在树莓派上运行：

```bash
# 下载部署脚本
wget https://raw.githubusercontent.com/panshuhan/immortalwrt-rpi4-builder/main/docker/deploy.sh

# 运行部署
chmod +x deploy.sh
./deploy.sh
```

### 方法 2：手动部署

```bash
# 1. 创建 macvlan 网络
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  --ip-range=192.168.1.2/32 \
  -o parent=eth0 \
  openwrt-net

# 2. 运行容器
docker run -d \
  --name immortalwrt-bypass \
  --network openwrt-net \
  --ip 192.168.1.2 \
  --restart always \
  --privileged \
  --cap-add NET_ADMIN \
  --cap-add NET_RAW \
  -e TZ=Asia/Shanghai \
  ghcr.io/panshuhan/immortalwrt-rpi4-bypass:latest

# 3. 访问 Web 界面
# 浏览器打开：http://192.168.1.2
```

### 方法 3：使用 Docker Compose

```bash
# 1. 下载 docker-compose.yml
wget https://raw.githubusercontent.com/panshuhan/immortalwrt-rpi4-builder/main/docker/docker-compose.yml

# 2. 修改配置（可选）
# 编辑 docker-compose.yml 中的 IP 地址

# 3. 启动
docker-compose up -d
```

## 配置说明

### 默认设置

- **旁路由 IP**: 192.168.1.2
- **主路由网关**: 192.168.1.1
- **时区**: Asia/Shanghai
- **默认密码**: 无（首次登录请立即设置）

### 修改 IP 地址

如果你的网络不是 192.168.1.x，需要修改：

**方法 1: 修改 docker-compose.yml**
```yaml
networks:
  openwrt-net:
    ipam:
      config:
        - subnet: 192.168.10.0/24  # 改为你的网段
          gateway: 192.168.10.1    # 改为你的主路由
          ip_range: 192.168.10.2/32 # 改为旁路由 IP
```

**方法 2: 修改部署脚本**
编辑 `deploy.sh`，修改变量：
```bash
BYPASS_IP="192.168.10.2"
GATEWAY_IP="192.168.10.1"
```

### 客户端配置

**方法 1: 单个设备配置**
在需要科学上网的设备上：
- 手动设置网关：192.168.1.2
- 手动设置 DNS：192.168.1.2

**方法 2: 全局配置（推荐）**
在主路由器管理界面：
- DHCP 网关：改为 192.168.1.2
- DHCP DNS：改为 192.168.1.2

## 包含的功能

### 代理工具
- ✅ Passwall（中文界面）
- ✅ OpenClash（英文界面）

### 系统工具
- ✅ DDNS（动态域名）
- ✅ UPnP（端口映射）
- ✅ Samba4（文件共享）
- ✅ vsFTPd（FTP 服务器）
- ✅ TTYd（Web 终端）

## 常用命令

```bash
# 查看日志
docker logs -f immortalwrt-bypass

# 停止容器
docker stop immortalwrt-bypass

# 启动容器
docker start immortalwrt-bypass

# 重启容器
docker restart immortalwrt-bypass

# 进入容器 Shell
docker exec -it immortalwrt-bypass /bin/sh

# 删除容器
docker stop immortalwrt-bypass
docker rm immortalwrt-bypass

# 查看容器状态
docker ps | grep immortalwrt
```

## 故障排查

### 无法访问 Web 界面

1. 检查容器是否运行：
   ```bash
   docker ps | grep immortalwrt
   ```

2. 检查网络配置：
   ```bash
   docker network inspect openwrt-net
   ```

3. 检查容器日志：
   ```bash
   docker logs immortalwrt-bypass
   ```

### 无法科学上网

1. 确认已配置客户端网关/DNS 为旁路由 IP
2. 登录 Web 界面检查代理工具配置
3. 检查 Passwall/OpenClash 服务是否启动

### 容器重启后配置丢失

挂载数据卷保存配置：
```bash
docker run -d \
  ... \
  -v ./immortalwrt-data:/overlay \
  ...
```

## 自定义构建

如果需要自定义包列表：

1. 克隆仓库：
   ```bash
   git clone https://github.com/panshuhan/immortalwrt-rpi4-builder.git
   cd immortalwrt-rpi4-builder/docker
   ```

2. 修改 Dockerfile 中的包列表

3. 构建镜像：
   ```bash
   ./build.sh
   ```

4. 运行自定义镜像：
   ```bash
   docker run -d --name immortalwrt-bypass ... immortalwrt-rpi4-bypass:latest
   ```

## 性能优化

### 树莓派 4 优化建议

1. **使用有线网络**：比 WiFi 更稳定
2. **散热**：安装散热片或风扇
3. **使用 SSD**：通过 USB 3.0 接 SSD 提升性能

### 代理性能优化

1. 在 Passwall/OpenClash 中选择快速节点
2. 启用 UDP 加速
3. 合理配置分流规则

## 安全建议

1. ✅ **立即设置密码**：首次登录后立即修改密码
2. ✅ **更新固件**：定期重新构建镜像获取更新
3. ✅ **防火墙规则**：只开放必要端口
4. ✅ **使用 HTTPS**：启用 SSL 证书

## 更新

### 更新镜像

```bash
# 停止并删除旧容器
docker stop immortalwrt-bypass
docker rm immortalwrt-bypass

# 拉取新镜像
docker pull ghcr.io/panshuhan/immortalwrt-rpi4-bypass:latest

# 重新运行
./deploy.sh
```

### 更新配置

修改后重新构建：
```bash
cd docker
./build.sh
docker-compose up -d --force-recreate
```

## 支持

- 项目地址：https://github.com/panshuhan/immortalwrt-rpi4-builder
- ImmortalWrt：https://github.com/immortalwrt/immortalwrt
- 问题反馈：https://github.com/panshuhan/immortalwrt-rpi4-builder/issues

## 许可证

MIT License
