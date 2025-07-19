# 股票数据可视化系统安装指南

## 🚀 快速开始

### 系统要求
- **操作系统**: Linux (Ubuntu 18.04+, CentOS 7+, Fedora) 或 macOS 10.14+
- **内存**: 至少 2GB RAM
- **磁盘空间**: 至少 1GB 可用空间
- **网络**: 需要互联网连接下载依赖

### 一键部署（推荐）

```bash
# 1. 下载项目
git clone <your-repository-url>
cd stock_data_project

# 2. 运行部署脚本
chmod +x deploy.sh
./deploy.sh
```

部署脚本会自动：
- ✅ 检测操作系统
- ✅ 安装缺失的依赖（Python3, Node.js, npm等）
- ✅ 创建虚拟环境
- ✅ 安装Python和Node.js依赖
- ✅ 构建前端应用
- ✅ 生成登录密码
- ✅ 创建启动脚本

### 手动安装（如果自动安装失败）

#### Linux (Ubuntu/Debian)

```bash
# 1. 更新系统
sudo apt update && sudo apt upgrade -y

# 2. 安装Python3
sudo apt install -y python3 python3-pip python3-venv

# 3. 安装Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# 4. 验证安装
python3 --version
node --version
npm --version

# 5. 运行部署脚本
./deploy.sh
```

#### Linux (CentOS/RHEL/Fedora)

```bash
# 1. 安装Python3
sudo yum install -y python3 python3-pip  # CentOS/RHEL
# 或
sudo dnf install -y python3 python3-pip  # Fedora

# 2. 安装Node.js 18.x
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs  # CentOS/RHEL
# 或
sudo dnf install -y nodejs  # Fedora

# 3. 运行部署脚本
./deploy.sh
```

#### macOS

```bash
# 1. 安装Homebrew（如果没有）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. 安装Python3和Node.js
brew install python3 node

# 3. 运行部署脚本
./deploy.sh
```

## 🔧 部署后操作

### 启动系统
```bash
./start.sh
```

### 停止系统
```bash
./stop.sh
```

### 查看登录密码
```bash
./show_password.sh
```

### 访问系统
- **地址**: http://localhost:5001
- **密码**: 运行 `./show_password.sh` 查看

## 🛠️ 故障排除

### 常见问题

#### 1. "未找到 node" 错误

**方法一：使用专用安装脚本**
```bash
chmod +x install_nodejs.sh
./install_nodejs.sh
```

**方法二：根据发行版手动安装**

**Ubuntu/Debian:**
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

**CentOS/RHEL/Rocky Linux:**
```bash
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs
```

**Fedora:**
```bash
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install -y nodejs
```

**openSUSE:**
```bash
sudo zypper addrepo https://download.opensuse.org/repositories/devel:languages:nodejs/openSUSE_Leap_15.4/devel:languages:nodejs.repo
sudo zypper refresh
sudo zypper install -y nodejs18
```

**Arch Linux/Manjaro:**
```bash
sudo pacman -S nodejs npm
```

**方法三：二进制安装**
```bash
# 下载并安装Node.js二进制版本
NODE_VERSION="18.19.0"
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    NODE_ARCH="x64"
elif [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
    NODE_ARCH="arm64"
else
    echo "不支持的架构: $ARCH"
    exit 1
fi

cd /tmp
wget -O nodejs.tar.xz "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz"
sudo tar -xf nodejs.tar.xz -C /usr/local --strip-components=1
sudo ln -sf /usr/local/bin/node /usr/bin/node
sudo ln -sf /usr/local/bin/npm /usr/bin/npm
rm nodejs.tar.xz
```

#### 2. "权限被拒绝" 错误
```bash
# 给脚本添加执行权限
chmod +x deploy.sh start.sh stop.sh show_password.sh
```

#### 3. "端口被占用" 错误
```bash
# 检查端口占用
lsof -i :5001

# 停止占用端口的进程
sudo kill -9 <PID>
```

#### 4. "Python依赖安装失败"
```bash
# 清理并重新安装
cd backend_api
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

#### 5. "前端构建失败"
```bash
# 清理并重新安装
cd frontend
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps
npm run build:prod
```

### 日志查看

#### 后端日志
```bash
cd backend_api
source venv/bin/activate
python3 bidding_api.py
```

#### 前端日志
```bash
cd frontend
npm start
```

## 📁 项目结构

```
stock_data_project/
├── backend_api/          # 后端API服务
│   ├── copy_bidding/     # CSV数据文件（需要手动添加）
│   ├── venv/            # Python虚拟环境
│   ├── password.json    # 密码文件（自动生成）
│   ├── bidding_api.py   # 主API文件
│   └── requirements.txt # Python依赖
├── frontend/            # 前端React应用
│   ├── build/           # 生产构建文件
│   ├── src/             # 源代码
│   └── package.json     # Node.js依赖
├── deploy.sh           # 部署脚本
├── start.sh            # 启动脚本
├── stop.sh             # 停止脚本
├── show_password.sh    # 密码查看脚本
├── .env                # 环境变量（自动生成）
└── README.md           # 项目说明
```

## 🔐 安全配置

### 环境变量
系统会自动创建 `.env` 文件，包含：
- `API_TOKEN`: API访问令牌
- `DEVICE_ID`: 设备ID
- `USER_ID`: 用户ID
- `PORT`: 服务端口（5001）

### 密码管理
- 系统会自动生成随机密码
- 密码存储在 `backend_api/password.json`
- 使用 `./show_password.sh` 查看密码

## 📊 数据文件

### 添加CSV数据
1. 创建目录：`mkdir -p backend_api/copy_bidding`
2. 将CSV文件放入该目录
3. 文件命名格式：`bidding_YYYY-MM-DD_HHMMSS_limit.csv`

### 数据格式
CSV文件应包含以下列：
- 股票代码
- 股票名称
- 开盘价
- 封单金额
- 竞价涨幅
- 板块信息
- 其他相关数据

## 🚀 生产部署

### 使用Docker
```bash
# 构建镜像
docker build -t stock-data-app .

# 运行容器
docker run -d -p 5001:5001 -v ./backend_api/copy_bidding:/app/backend_api/copy_bidding stock-data-app
```

### 使用Docker Compose
```bash
docker-compose up -d
```

## 📞 技术支持

如果遇到问题：
1. 查看本文档的故障排除部分
2. 检查系统日志
3. 确认所有依赖已正确安装
4. 验证数据文件格式正确

---

**祝您使用愉快！** 🎉 