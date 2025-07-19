#!/bin/bash

# Node.js 安装脚本
# 支持多种Linux发行版

set -e

echo "🚀 Node.js 安装脚本"
echo "===================="

# 检测操作系统
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    echo "📋 检测到操作系统: Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    echo "📋 检测到操作系统: macOS"
else
    echo "❌ 不支持的操作系统: $OSTYPE"
    exit 1
fi

# 检查是否已安装
if command -v node &> /dev/null; then
    echo "✅ Node.js 已安装: $(node --version)"
    echo "✅ npm 已安装: $(npm --version)"
    exit 0
fi

if [[ "$OS" == "linux" ]]; then
    # 检测Linux发行版
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$NAME
        OS_VERSION=$VERSION_ID
        OS_ID=$ID
    else
        OS_NAME="Unknown"
        OS_VERSION="Unknown"
        OS_ID="unknown"
    fi
    
    echo "📋 检测到Linux发行版: $OS_NAME $OS_VERSION ($OS_ID)"
    
    # 根据发行版安装Node.js
    case $OS_ID in
        "ubuntu"|"debian"|"linuxmint")
            echo "📦 使用 apt-get 安装 Node.js..."
            sudo apt-get update
            sudo apt-get install -y curl
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        "centos"|"rhel"|"rocky"|"almalinux")
            echo "📦 使用 yum 安装 Node.js..."
            sudo yum install -y curl
            echo "📦 添加 NodeSource 仓库..."
            # 使用更兼容的方式添加仓库
            curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash - || {
                echo "⚠️  NodeSource 仓库添加失败，尝试使用系统仓库..."
                sudo yum install -y nodejs npm || {
                    echo "⚠️  系统仓库安装失败，尝试二进制安装..."
                    install_nodejs_binary
                }
            }
            ;;
        "fedora")
            echo "📦 使用 dnf 安装 Node.js..."
            sudo dnf install -y curl
            curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
            sudo dnf install -y nodejs
            ;;
        "opensuse"|"opensuse-leap"|"tumbleweed")
            echo "📦 使用 zypper 安装 Node.js..."
            sudo zypper addrepo https://download.opensuse.org/repositories/devel:languages:nodejs/openSUSE_Leap_15.4/devel:languages:nodejs.repo
            sudo zypper refresh
            sudo zypper install -y nodejs18
            ;;
        "arch"|"manjaro")
            echo "📦 使用 pacman 安装 Node.js..."
            sudo pacman -S --noconfirm nodejs npm
            ;;
        *)
            echo "⚠️  未知的Linux发行版，尝试使用二进制安装..."
            install_nodejs_binary
            ;;
    esac
    
elif [[ "$OS" == "macos" ]]; then
    echo "📦 使用 Homebrew 安装 Node.js..."
    if ! command -v brew &> /dev/null; then
        echo "📦 安装 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install node
fi

# 验证安装
if command -v node &> /dev/null; then
    echo "✅ Node.js 安装成功: $(node --version)"
    echo "✅ npm 安装成功: $(npm --version)"
else
    echo "❌ Node.js 安装失败"
    echo ""
    echo "🔧 请尝试手动安装:"
    echo "1. 访问 https://nodejs.org/ 下载安装包"
    echo "2. 或使用系统包管理器:"
    case $OS_ID in
        "ubuntu"|"debian") echo "   sudo apt-get install nodejs npm" ;;
        "centos"|"rhel") echo "   sudo yum install nodejs npm" ;;
        "fedora") echo "   sudo dnf install nodejs npm" ;;
        *) echo "   请查看 https://nodejs.org/ 获取安装指南" ;;
    esac
    exit 1
fi

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