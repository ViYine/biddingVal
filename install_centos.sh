#!/bin/bash

# CentOS 专用安装脚本
# 解决 NodeSource 仓库问题

set -e

echo "🚀 CentOS 专用安装脚本"
echo "======================="

# 检查是否为CentOS
if [ ! -f /etc/redhat-release ]; then
    echo "❌ 此脚本仅适用于 CentOS/RHEL 系统"
    exit 1
fi

echo "📋 检测到系统: $(cat /etc/redhat-release)"

# 检查是否为root用户
if [[ $EUID -eq 0 ]]; then
    echo "⚠️  检测到root用户，建议使用普通用户运行此脚本"
    read -p "是否继续？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "🔍 检查系统依赖..."

# 安装基础工具
install_package() {
    local package=$1
    if ! command -v $package &> /dev/null; then
        echo "📦 安装 $package..."
        sudo yum install -y $package
    else
        echo "✅ $package 已安装"
    fi
}

# 安装基础依赖
install_package "curl"
install_package "wget"
install_package "git"
install_package "python3"
install_package "python3-pip"

# 检查Python虚拟环境
if ! python3 -c "import venv" 2>/dev/null; then
    echo "📦 安装 python3-venv..."
    sudo yum install -y python3-venv || sudo yum install -y python3-virtualenv
fi

echo ""
echo "📦 安装 Node.js..."

# 方法1: 尝试使用系统仓库
if ! command -v node &> /dev/null; then
    echo "📦 方法1: 尝试使用系统仓库..."
    if sudo yum install -y nodejs npm; then
        echo "✅ 使用系统仓库安装成功"
    else
        echo "⚠️  系统仓库安装失败"
        
        # 方法2: 尝试使用EPEL仓库
        echo "📦 方法2: 尝试使用EPEL仓库..."
        if ! sudo yum repolist | grep -q epel; then
            echo "📦 安装EPEL仓库..."
            sudo yum install -y epel-release
        fi
        
        if sudo yum install -y nodejs npm; then
            echo "✅ 使用EPEL仓库安装成功"
        else
            echo "⚠️  EPEL仓库安装失败"
            
            # 方法3: 尝试使用NodeSource仓库
            echo "📦 方法3: 尝试使用NodeSource仓库..."
            if curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -; then
                if sudo yum install -y nodejs; then
                    echo "✅ 使用NodeSource仓库安装成功"
                else
                    echo "⚠️  NodeSource仓库安装失败"
                    install_nodejs_binary
                fi
            else
                echo "⚠️  NodeSource仓库添加失败"
                install_nodejs_binary
            fi
        fi
    fi
else
    echo "✅ Node.js 已安装"
fi

# 验证安装
echo ""
echo "🔍 验证安装..."
python3 --version
node --version
npm --version

echo ""
echo "🎉 CentOS 依赖安装完成！"
echo ""
echo "📋 下一步操作："
echo "1. 运行部署脚本: ./deploy.sh"
echo "2. 启动系统: ./start.sh"
echo "3. 访问系统: http://localhost:5001"

# 二进制安装函数
install_nodejs_binary() {
    echo "📦 使用二进制方式安装 Node.js..."
    
    NODE_VERSION="18.19.0"
    ARCH=$(uname -m)
    
    case $ARCH in
        "x86_64") NODE_ARCH="x64" ;;
        "aarch64"|"arm64") NODE_ARCH="arm64" ;;
        "i686"|"i386") NODE_ARCH="x86" ;;
        *) 
            echo "❌ 不支持的架构: $ARCH"
            exit 1
            ;;
    esac
    
    echo "📦 下载 Node.js $NODE_VERSION ($NODE_ARCH)..."
    
    # 创建临时目录
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # 下载Node.js
    if command -v wget &> /dev/null; then
        wget -O nodejs.tar.xz "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz"
    elif command -v curl &> /dev/null; then
        curl -L -o nodejs.tar.xz "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz"
    else
        echo "❌ 需要 wget 或 curl 来下载文件"
        exit 1
    fi
    
    if [ $? -eq 0 ]; then
        echo "📦 解压 Node.js..."
        sudo tar -xf nodejs.tar.xz -C /usr/local --strip-components=1
        sudo ln -sf /usr/local/bin/node /usr/bin/node
        sudo ln -sf /usr/local/bin/npm /usr/bin/npm
        
        # 清理
        cd /
        rm -rf "$TEMP_DIR"
        
        echo "✅ Node.js 二进制安装成功"
    else
        echo "❌ Node.js 下载失败"
        exit 1
    fi
} 