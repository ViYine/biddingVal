#!/bin/bash

# 股票数据可视化系统一键部署脚本
# 支持 Linux/macOS 系统

set -e

echo "🚀 开始部署股票数据可视化系统..."

# 检查系统
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    echo "❌ 不支持的操作系统: $OSTYPE"
    exit 1
fi

echo "📋 检测到操作系统: $OS"

# 检查并安装必要的工具
check_and_install_command() {
    local cmd=$1
    local install_cmd=$2
    local package_name=$3
    
    if ! command -v $cmd &> /dev/null; then
        echo "⚠️  未找到 $cmd，尝试自动安装..."
        
        if [[ "$OS" == "linux" ]]; then
            # Linux系统
            if command -v apt-get &> /dev/null; then
                # Ubuntu/Debian
                echo "📦 使用 apt-get 安装 $package_name..."
                sudo apt-get update
                sudo apt-get install -y $package_name
            elif command -v yum &> /dev/null; then
                # CentOS/RHEL
                echo "📦 使用 yum 安装 $package_name..."
                sudo yum install -y $package_name
            elif command -v dnf &> /dev/null; then
                # Fedora
                echo "📦 使用 dnf 安装 $package_name..."
                sudo dnf install -y $package_name
            else
                echo "❌ 无法自动安装 $cmd，请手动安装"
                echo "   安装命令: $install_cmd"
                exit 1
            fi
        elif [[ "$OS" == "macos" ]]; then
            # macOS系统
            if command -v brew &> /dev/null; then
                echo "📦 使用 Homebrew 安装 $package_name..."
                brew install $package_name
            else
                echo "❌ 未找到 Homebrew，请先安装 Homebrew"
                echo "   安装命令: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                exit 1
            fi
        fi
        
        # 再次检查是否安装成功
        if ! command -v $cmd &> /dev/null; then
            echo "❌ $cmd 安装失败，请手动安装"
            echo "   安装命令: $install_cmd"
            exit 1
        else
            echo "✅ $cmd 安装成功"
        fi
    else
        echo "✅ $cmd 已安装"
    fi
}

echo "🔍 检查系统依赖..."
check_and_install_command "python3" "sudo apt-get install python3" "python3"
check_and_install_command "pip3" "sudo apt-get install python3-pip" "python3-pip"

# 特殊处理 Node.js 和 npm
if ! command -v node &> /dev/null; then
    echo "⚠️  未找到 node，尝试自动安装..."
    
    if [[ "$OS" == "linux" ]]; then
        # 检测Linux发行版
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS_NAME=$NAME
            OS_VERSION=$VERSION_ID
        else
            OS_NAME="Unknown"
            OS_VERSION="Unknown"
        fi
        
        echo "📋 检测到Linux发行版: $OS_NAME $OS_VERSION"
        
        if command -v apt-get &> /dev/null; then
            # Debian/Ubuntu系统
            echo "📦 使用 apt-get 安装 Node.js..."
            if command -v curl &> /dev/null; then
                echo "📦 添加 NodeSource 仓库..."
                curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
                sudo apt-get install -y nodejs
            else
                echo "📦 安装 curl..."
                sudo apt-get update
                sudo apt-get install -y curl
                echo "📦 添加 NodeSource 仓库..."
                curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
                sudo apt-get install -y nodejs
            fi
        elif command -v yum &> /dev/null; then
            # CentOS/RHEL系统
            echo "📦 使用 yum 安装 Node.js..."
            if command -v curl &> /dev/null; then
                echo "📦 添加 NodeSource 仓库..."
                curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
                sudo yum install -y nodejs
            else
                echo "📦 安装 curl..."
                sudo yum install -y curl
                echo "📦 添加 NodeSource 仓库..."
                curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
                sudo yum install -y nodejs
            fi
        elif command -v dnf &> /dev/null; then
            # Fedora系统
            echo "📦 使用 dnf 安装 Node.js..."
            if command -v curl &> /dev/null; then
                echo "📦 添加 NodeSource 仓库..."
                curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
                sudo dnf install -y nodejs
            else
                echo "📦 安装 curl..."
                sudo dnf install -y curl
                echo "📦 添加 NodeSource 仓库..."
                curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
                sudo dnf install -y nodejs
            fi
        elif command -v zypper &> /dev/null; then
            # openSUSE系统
            echo "📦 使用 zypper 安装 Node.js..."
            sudo zypper addrepo https://download.opensuse.org/repositories/devel:languages:nodejs/openSUSE_Leap_15.4/devel:languages:nodejs.repo
            sudo zypper refresh
            sudo zypper install -y nodejs18
        else
            echo "❌ 不支持的包管理器，尝试使用 Node.js 二进制安装..."
            
            # 下载并安装Node.js二进制版本
            NODE_VERSION="18.19.0"
            ARCH=$(uname -m)
            
            if [[ "$ARCH" == "x86_64" ]]; then
                NODE_ARCH="x64"
            elif [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
                NODE_ARCH="arm64"
            else
                echo "❌ 不支持的架构: $ARCH"
                exit 1
            fi
            
            echo "📦 下载 Node.js $NODE_VERSION ($NODE_ARCH)..."
            cd /tmp
            wget -O nodejs.tar.xz "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz"
            
            if [ $? -eq 0 ]; then
                echo "📦 解压 Node.js..."
                sudo tar -xf nodejs.tar.xz -C /usr/local --strip-components=1
                sudo ln -sf /usr/local/bin/node /usr/bin/node
                sudo ln -sf /usr/local/bin/npm /usr/bin/npm
                rm nodejs.tar.xz
                cd - > /dev/null
            else
                echo "❌ Node.js 下载失败"
                exit 1
            fi
        fi
    elif [[ "$OS" == "macos" ]]; then
        # macOS系统
        if command -v brew &> /dev/null; then
            echo "📦 使用 Homebrew 安装 Node.js..."
            brew install node
        else
            echo "❌ 未找到 Homebrew，请先安装 Homebrew"
            echo "   安装命令: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
    fi
    
    # 再次检查
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js 自动安装失败"
        echo ""
        echo "🔧 请手动安装 Node.js:"
        echo "1. 访问 https://nodejs.org/ 下载安装包"
        echo "2. 或使用系统包管理器安装:"
        if command -v apt-get &> /dev/null; then
            echo "   sudo apt-get install nodejs npm"
        elif command -v yum &> /dev/null; then
            echo "   sudo yum install nodejs npm"
        elif command -v dnf &> /dev/null; then
            echo "   sudo dnf install nodejs npm"
        fi
        echo ""
        echo "安装完成后重新运行此脚本"
        exit 1
    else
        echo "✅ Node.js 安装成功"
    fi
else
    echo "✅ node 已安装"
fi

# npm 通常随 Node.js 一起安装
if ! command -v npm &> /dev/null; then
    echo "❌ npm 未找到，请重新安装 Node.js"
    exit 1
else
    echo "✅ npm 已安装"
fi

# 创建项目目录
PROJECT_DIR="stock_data_project"

# 检查当前目录结构
if [ -d "backend_api" ] && [ -d "frontend" ]; then
    # 已经在stock_data_project目录内
    echo "✅ 检测到项目结构，在项目目录内运行"
    PROJECT_DIR="."
elif [ -d "$PROJECT_DIR" ]; then
    # 在上级目录，需要进入项目目录
    echo "✅ 进入项目目录: $PROJECT_DIR"
    cd "$PROJECT_DIR"
else
    echo "❌ 项目目录不存在，请确保在正确的目录下运行此脚本"
    echo "   当前目录: $(pwd)"
    echo "   期望找到: backend_api/ 和 frontend/ 目录"
    exit 1
fi

cd "$PROJECT_DIR"

# 后端部署
echo "🔧 部署后端服务..."

cd backend_api

# 创建虚拟环境
if [ ! -d "venv" ]; then
    echo "📦 创建Python虚拟环境..."
    python3 -m venv venv
fi

# 激活虚拟环境
echo "🔌 激活虚拟环境..."
source venv/bin/activate

# 安装依赖
echo "📥 安装Python依赖..."
pip install --upgrade pip
pip install -r requirements.txt

# 生成随机密码
echo "🔐 生成随机登录密码..."
python3 password_generator.py

# 读取生成的密码
if [ -f "password.json" ]; then
    PASSWORD=$(python3 -c "import json; print(json.load(open('password.json'))['password'])")
    echo "✅ 密码生成成功: $PASSWORD"
else
    echo "❌ 密码生成失败"
    exit 1
fi

# 检查数据文件
if [ ! -d "copy_bidding" ]; then
    echo "⚠️  警告: 未找到数据目录 copy_bidding"
    echo "请确保将CSV数据文件放在 backend_api/copy_bidding/ 目录下"
fi

cd ..

# 前端部署
echo "🎨 部署前端应用..."

cd frontend

# 安装依赖
echo "📥 安装Node.js依赖..."
npm install --legacy-peer-deps

# 构建生产版本
echo "🏗️  构建前端生产版本..."
if ! npm run build:prod; then
    echo "⚠️  前端构建失败，尝试修复..."
    
    # 尝试修复依赖
    echo "🔧 尝试修复依赖..."
    rm -rf node_modules package-lock.json
    npm cache clean --force
    npm install --legacy-peer-deps
    
    # 再次尝试构建
    if ! npm run build:prod; then
        echo "❌ 前端构建仍然失败，尝试修复npm包问题..."
        
        # 检查是否有npm包修复脚本
        if [ -f "../fix_npm_packages.sh" ]; then
            cd ..
            chmod +x fix_npm_packages.sh
            if ./fix_npm_packages.sh; then
                cd frontend
            else
                echo "⚠️  npm包修复失败，尝试迁移到Vite..."
        
        # 检查是否有Vite迁移脚本
        if [ -f "../migrate_to_vite.sh" ]; then
            cd ..
            chmod +x migrate_to_vite.sh
            if ./migrate_to_vite.sh; then
                cd frontend
            else
                echo "⚠️  Vite迁移失败，尝试简化迁移..."
                if [ -f "migrate_to_vite_simple.sh" ]; then
                    chmod +x migrate_to_vite_simple.sh
                    if ./migrate_to_vite_simple.sh; then
                        cd frontend
                    else
                        echo "⚠️  简化Vite迁移也失败，尝试修复Create React App..."
                        if [ -f "fix_cra.sh" ]; then
                            chmod +x fix_cra.sh
                            if ./fix_cra.sh; then
                                cd frontend
                            else
                                echo "❌ 所有修复方法都失败了"
                                echo "请手动运行: ./fix_cra.sh 或 ./quick_fix.sh"
                                exit 1
                            fi
                        else
                            echo "❌ 无法修复前端构建问题"
                            echo "请手动运行: ./fix_frontend.sh 或 ./migrate_to_vite.sh"
                            exit 1
                        fi
                    fi
                else
                    echo "❌ 无法修复前端构建问题"
                    echo "请手动运行: ./fix_frontend.sh 或 ./migrate_to_vite.sh"
                    exit 1
                fi
            fi
        else
            echo "❌ 无法修复前端构建问题"
            echo "请手动运行: ./fix_frontend.sh 或 ./migrate_to_vite.sh"
            exit 1
        fi
    fi
fi

cd ..

# 创建启动脚本
echo "📝 创建启动脚本..."

cat > start.sh << 'EOF'
#!/bin/bash

# 股票数据可视化系统启动脚本

echo "🚀 启动股票数据可视化系统..."

# 读取当前密码
if [ -f "backend_api/password.json" ]; then
    PASSWORD=$(python3 -c "import json; print(json.load(open('backend_api/password.json'))['password'])")
    echo "🔐 当前登录密码: $PASSWORD"
else
    echo "❌ 密码文件不存在"
    exit 1
fi

# 启动后端服务
echo "🔧 启动后端服务..."
cd backend_api

# 检查虚拟环境
if [ ! -d "venv" ]; then
    echo "❌ 虚拟环境不存在，请先运行 ./deploy.sh"
    exit 1
fi

# 激活虚拟环境
echo "🔌 激活虚拟环境..."
source venv/bin/activate

# 检查依赖
echo "🔍 检查Python依赖..."
python3 -c "import flask, pandas, numpy, requests, gunicorn" 2>/dev/null || {
    echo "❌ Python依赖不完整，请重新运行 ./deploy.sh"
    exit 1
}

# 使用Gunicorn启动生产服务
echo "🌐 启动API服务器 (端口: 5001)..."
gunicorn -c gunicorn.conf.py bidding_api:app &
BACKEND_PID=$!
echo "✅ 后端服务已启动 (PID: $BACKEND_PID)"

# 等待后端启动
echo "⏳ 等待服务启动..."
for i in {1..10}; do
            if curl -f http://localhost:5001/api/health > /dev/null 2>&1; then
        echo "✅ 后端服务运行正常"
        break
    fi
    if [ $i -eq 10 ]; then
        echo "❌ 后端服务启动失败"
        echo "🔍 检查进程状态..."
        ps aux | grep gunicorn | grep -v grep || echo "进程未找到"
        echo "🔍 检查端口占用..."
        lsof -i :5001 || echo "端口5001未被占用"
        echo "🔍 检查日志..."
        echo "请手动运行以下命令查看详细错误:"
        echo "cd backend_api && source venv/bin/activate && python3 bidding_api.py"
        kill $BACKEND_PID 2>/dev/null || true
        exit 1
    fi
    sleep 1
done

echo ""
echo "🎉 股票数据可视化系统启动成功!"
echo "📊 访问地址: http://localhost:5001"
echo "🔑 登录密码: $PASSWORD"
echo ""
echo "按 Ctrl+C 停止服务"

# 等待用户中断
wait $BACKEND_PID
EOF

chmod +x start.sh

# 创建停止脚本
cat > stop.sh << 'EOF'
#!/bin/bash

echo "🛑 停止股票数据可视化系统..."

# 停止后端服务
pkill -f "gunicorn.*bidding_api:app" || true

echo "✅ 服务已停止"
EOF

chmod +x stop.sh

# 创建密码查看脚本
cat > show_password.sh << 'EOF'
#!/bin/bash

echo "🔐 查看当前登录密码..."

if [ -f "backend_api/password.json" ]; then
    PASSWORD=$(python3 -c "import json; print(json.load(open('backend_api/password.json'))['password'])")
    echo "当前登录密码: $PASSWORD"
else
    echo "❌ 密码文件不存在"
fi
EOF

chmod +x show_password.sh

# 创建Docker部署文件（可选）
echo "🐳 创建Docker配置..."

cat > Dockerfile << 'EOF'
# 多阶段构建
FROM node:18-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci --only=production
COPY frontend/ ./
RUN npm run build:prod

FROM python:3.9-slim
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 复制后端代码
COPY backend_api/ ./backend_api/
WORKDIR /app/backend_api

# 安装Python依赖
RUN pip install --no-cache-dir -r requirements.txt

# 生成随机密码
RUN python3 password_generator.py

# 复制前端构建文件
COPY --from=frontend-builder /app/frontend/build ../frontend/build

# 暴露端口
EXPOSE 5000

# 启动命令
CMD ["gunicorn", "-c", "gunicorn.conf.py", "bidding_api:app"]
EOF

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  stock-data-app:
    build: .
    ports:
      - "5000:5000"
    volumes:
      - ./backend_api/copy_bidding:/app/backend_api/copy_bidding
    environment:
      - FLASK_ENV=production
    restart: unless-stopped
EOF

cat > .dockerignore << 'EOF'
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.venv
__pycache__
*.pyc
*.pyo
*.pyd
.Python
env
pip-log.txt
pip-delete-this-directory.txt
.tox
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.log
.git
.mypy_cache
.pytest_cache
.hypothesis
EOF

echo ""
echo "🎉 部署完成!"
echo ""
echo "📋 部署信息:"
echo "   - 后端API: http://localhost:5001"
echo "   - 前端应用: http://localhost:5001"
echo "   - 登录密码: $PASSWORD"
echo ""
echo "🚀 启动方式:"
echo "   1. 直接启动: ./start.sh"
echo "   2. Docker启动: docker-compose up -d"
echo "   3. 手动启动:"
echo "      - 后端: cd stock_data_project/backend_api && source venv/bin/activate && gunicorn -c gunicorn.conf.py bidding_api:app"
echo "      - 前端: cd stock_data_project/frontend && npm start"
echo ""
echo "🛑 停止服务: ./stop.sh"
echo "🔐 查看密码: ./show_password.sh"
echo ""
echo "📁 项目结构:"
echo "   stock_data_project/"
echo "   ├── backend_api/          # 后端API服务"
echo "   │   ├── copy_bidding/     # CSV数据文件"
echo "   │   ├── venv/            # Python虚拟环境"
echo "   │   ├── password.json    # 密码文件"
echo "   │   └── bidding_api.py   # 主API文件"
echo "   ├── frontend/            # 前端React应用"
echo "   │   ├── build/           # 生产构建文件"
echo "   │   └── src/             # 源代码"
echo "   ├── start.sh             # 启动脚本"
echo "   ├── stop.sh              # 停止脚本"
echo "   ├── show_password.sh     # 密码查看脚本"
echo "   ├── Dockerfile           # Docker配置"
echo "   └── docker-compose.yml   # Docker Compose配置"
echo ""
echo "✅ 部署完成，可以开始使用了!"
echo "🔑 请记住您的登录密码: $PASSWORD" 