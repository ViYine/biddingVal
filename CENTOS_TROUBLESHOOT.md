# CentOS 故障排除指南

## 常见问题及解决方案

### 1. NodeSource 仓库错误

**错误信息:**
```
Error: This script is intended for RPM-based systems. Please run it on an RPM-based system.
```

**解决方案:**

**方法1: 使用CentOS专用脚本**
```bash
chmod +x install_centos.sh
./install_centos.sh
```

**方法2: 手动安装Node.js**
```bash
# 方法1: 使用系统仓库
sudo yum install -y nodejs npm

# 方法2: 使用EPEL仓库
sudo yum install -y epel-release
sudo yum install -y nodejs npm

# 方法3: 二进制安装
NODE_VERSION="18.19.0"
cd /tmp
wget -O nodejs.tar.xz "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz"
sudo tar -xf nodejs.tar.xz -C /usr/local --strip-components=1
sudo ln -sf /usr/local/bin/node /usr/bin/node
sudo ln -sf /usr/local/bin/npm /usr/bin/npm
rm nodejs.tar.xz
```

### 2. Python3 虚拟环境问题

**错误信息:**
```
ModuleNotFoundError: No module named 'venv'
```

**解决方案:**
```bash
# 安装python3-venv
sudo yum install -y python3-venv

# 或者安装python3-virtualenv
sudo yum install -y python3-virtualenv
```

### 3. 权限问题

**错误信息:**
```
Permission denied
```

**解决方案:**
```bash
# 确保脚本有执行权限
chmod +x *.sh

# 如果使用root用户，建议切换到普通用户
sudo useradd -m -s /bin/bash stockuser
sudo usermod -aG wheel stockuser
su - stockuser
```

### 4. 端口被占用

**错误信息:**
```
Address already in use
```

**解决方案:**
```bash
# 查看端口占用
sudo lsof -i :5001

# 杀死占用进程
sudo kill -9 <PID>

# 或者停止所有相关进程
sudo pkill -f gunicorn
sudo pkill -f node
```

### 5. 防火墙问题

**解决方案:**
```bash
# 开放端口
sudo firewall-cmd --permanent --add-port=5001/tcp
sudo firewall-cmd --reload

# 或者临时关闭防火墙（不推荐）
sudo systemctl stop firewalld
```

### 6. SELinux 问题

**解决方案:**
```bash
# 检查SELinux状态
sestatus

# 临时禁用SELinux
sudo setenforce 0

# 永久禁用SELinux（需要重启）
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
```

## 快速诊断

运行故障排除脚本：
```bash
chmod +x troubleshoot.sh
./troubleshoot.sh
```

## 系统要求

- CentOS 7 或更高版本
- 至少 1GB 内存
- 至少 2GB 磁盘空间
- 网络连接

## 推荐安装顺序

1. **安装系统依赖:**
   ```bash
   ./install_centos.sh
   ```

2. **部署应用:**
   ```bash
   ./deploy.sh
   ```

3. **启动系统:**
   ```bash
   ./start.sh
   ```

4. **访问系统:**
   ```
   http://localhost:5001
   ```

## 日志查看

```bash
# 查看后端日志
tail -f backend_api/logs/app.log

# 查看系统日志
journalctl -u stock-data-system -f

# 查看错误日志
tail -f /var/log/messages
```

## 联系支持

如果遇到其他问题，请提供以下信息：
- CentOS 版本: `cat /etc/redhat-release`
- 系统架构: `uname -m`
- 错误日志
- 故障排除脚本输出 