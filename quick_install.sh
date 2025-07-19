#!/bin/bash

# 股票数据可视化系统快速安装脚本
# 适用于新电脑的快速部署

set -e

echo "🚀 股票数据可视化系统快速安装"
echo "=================================="

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

# 安装函数
install_package() {
    local package=$1
    local install_cmd=$2
    
    if ! command -v $package &> /dev/null; then
        echo "📦 安装 $package..."
        eval $install_cmd
    else
        echo "✅ $package 已安装"
    fi
}

# 根据操作系统安装依赖
if [[ "$OS" == "linux" ]]; then
    # 检测包管理器
    if command -v apt-get &> /dev/null; then
        echo "📦 使用 apt-get 包管理器"
        
        # 更新包列表
        echo "🔄 更新包列表..."
        sudo apt-get update
        
        # 安装基础工具
        install_package "curl" "sudo apt-get install -y curl"
        install_package "wget" "sudo apt-get install -y wget"
        install_package "git" "sudo apt-get install -y git"
        
        # 安装Python3
        install_package "python3" "sudo apt-get install -y python3"
        install_package "pip3" "sudo apt-get install -y python3-pip"
        install_package "python3-venv" "sudo apt-get install -y python3-venv"
        
        # 安装Node.js 18.x
        if ! command -v node &> /dev/null; then
            echo "📦 安装 Node.js 18.x..."
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            sudo apt-get install -y nodejs
        else
            echo "✅ Node.js 已安装"
        fi
        
    elif command -v yum &> /dev/null; then
        echo "📦 使用 yum 包管理器"
        
        # 安装基础工具
        install_package "curl" "sudo yum install -y curl"
        install_package "wget" "sudo yum install -y wget"
        install_package "git" "sudo yum install -y git"
        
        # 安装Python3
        install_package "python3" "sudo yum install -y python3"
        install_package "pip3" "sudo yum install -y python3-pip"
        
        # 安装Node.js 18.x
        if ! command -v node &> /dev/null; then
            echo "📦 安装 Node.js 18.x..."
            curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
            sudo yum install -y nodejs
        else
            echo "✅ Node.js 已安装"
        fi
        
    elif command -v dnf &> /dev/null; then
        echo "📦 使用 dnf 包管理器"
        
        # 安装基础工具
        install_package "curl" "sudo dnf install -y curl"
        install_package "wget" "sudo dnf install -y wget"
        install_package "git" "sudo dnf install -y git"
        
        # 安装Python3
        install_package "python3" "sudo dnf install -y python3"
        install_package "pip3" "sudo dnf install -y python3-pip"
        
        # 安装Node.js 18.x
        if ! command -v node &> /dev/null; then
            echo "📦 安装 Node.js 18.x..."
            curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
            sudo dnf install -y nodejs
        else
            echo "✅ Node.js 已安装"
        fi
        
    else
        echo "❌ 不支持的包管理器，请手动安装依赖"
        exit 1
    fi
    
elif [[ "$OS" == "macos" ]]; then
    echo "📦 使用 Homebrew 包管理器"
    
    # 检查Homebrew
    if ! command -v brew &> /dev/null; then
        echo "📦 安装 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # 添加Homebrew到PATH
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo "✅ Homebrew 已安装"
    fi
    
    # 安装依赖
    install_package "python3" "brew install python3"
    install_package "node" "brew install node"
    install_package "git" "brew install git"
fi

echo ""
echo "✅ 系统依赖检查完成"
echo ""

# 验证安装
echo "🔍 验证安装..."
python3 --version
node --version
npm --version

echo ""
echo "🎉 系统依赖安装完成！"
echo ""
echo "📋 下一步操作："
echo "1. 运行部署脚本: ./deploy.sh"
echo "2. 启动系统: ./start.sh"
echo "3. 访问系统: http://localhost:5001"
echo ""
echo "📖 详细说明请查看: INSTALL_GUIDE.md" 