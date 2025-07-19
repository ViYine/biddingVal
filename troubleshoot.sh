#!/bin/bash

# 股票数据可视化系统故障排除脚本

echo "🔧 股票数据可视化系统故障排除"
echo "================================"

# 检测操作系统
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    echo "📋 操作系统: Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    echo "📋 操作系统: macOS"
else
    echo "📋 操作系统: $OSTYPE"
fi

echo ""

# 检查系统信息
echo "🔍 系统信息:"
echo "   - 架构: $(uname -m)"
echo "   - 内核: $(uname -r)"

if [[ "$OS" == "linux" ]] && [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "   - 发行版: $NAME $VERSION_ID"
fi

echo ""

# 检查依赖
echo "🔍 检查系统依赖:"

check_dependency() {
    local cmd=$1
    local name=$2
    if command -v $cmd &> /dev/null; then
        local version=$($cmd --version 2>/dev/null | head -1)
        echo "   ✅ $name: $version"
        return 0
    else
        echo "   ❌ $name: 未安装"
        return 1
    fi
}

python3_ok=false
node_ok=false
npm_ok=false

check_dependency "python3" "Python3" && python3_ok=true
check_dependency "pip3" "pip3" || echo "   ⚠️  pip3: 未安装"
check_dependency "node" "Node.js" && node_ok=true
check_dependency "npm" "npm" && npm_ok=true

echo ""

# 检查项目文件
echo "🔍 检查项目文件:"
if [ -d "backend_api" ]; then
    echo "   ✅ backend_api 目录存在"
else
    echo "   ❌ backend_api 目录不存在"
fi

if [ -d "frontend" ]; then
    echo "   ✅ frontend 目录存在"
else
    echo "   ❌ frontend 目录不存在"
fi

if [ -f "deploy.sh" ]; then
    echo "   ✅ deploy.sh 脚本存在"
else
    echo "   ❌ deploy.sh 脚本不存在"
fi

if [ -f ".env" ]; then
    echo "   ✅ .env 文件存在"
else
    echo "   ⚠️  .env 文件不存在"
fi

echo ""

# 检查端口占用
echo "🔍 检查端口占用:"
if command -v lsof &> /dev/null; then
    if lsof -i :5001 &> /dev/null; then
        echo "   ⚠️  端口 5001 被占用:"
        lsof -i :5001
    else
        echo "   ✅ 端口 5001 可用"
    fi
else
    echo "   ⚠️  无法检查端口占用 (lsof 未安装)"
fi

echo ""

# 检查进程
echo "🔍 检查相关进程:"
if pgrep -f "gunicorn.*bidding_api" > /dev/null; then
    echo "   ⚠️  发现后端进程:"
    pgrep -f "gunicorn.*bidding_api" | xargs ps -p
else
    echo "   ✅ 无后端进程运行"
fi

if pgrep -f "node.*start" > /dev/null; then
    echo "   ⚠️  发现前端进程:"
    pgrep -f "node.*start" | xargs ps -p
else
    echo "   ✅ 无前端进程运行"
fi

echo ""

# 提供解决方案
echo "🔧 解决方案:"

if ! $python3_ok; then
    echo "❌ Python3 未安装"
    if [[ "$OS" == "linux" ]]; then
        if command -v apt-get &> /dev/null; then
            echo "   运行: sudo apt-get install python3 python3-pip"
        elif command -v yum &> /dev/null; then
            echo "   运行: sudo yum install python3 python3-pip"
        elif command -v dnf &> /dev/null; then
            echo "   运行: sudo dnf install python3 python3-pip"
        fi
    elif [[ "$OS" == "macos" ]]; then
        echo "   运行: brew install python3"
    fi
    echo ""
fi

if ! $node_ok; then
    echo "❌ Node.js 未安装"
    echo "   运行: ./install_nodejs.sh"
    echo "   或访问: https://nodejs.org/ 下载安装"
    echo ""
fi

if ! $npm_ok; then
    echo "❌ npm 未安装"
    echo "   通常随 Node.js 一起安装，请重新安装 Node.js"
    echo ""
fi

# 检查虚拟环境
if [ -d "backend_api/venv" ]; then
    echo "✅ Python 虚拟环境存在"
else
    echo "⚠️  Python 虚拟环境不存在"
    echo "   运行: ./deploy.sh 重新部署"
    echo ""
fi

# 检查前端构建
if [ -d "frontend/build" ]; then
    echo "✅ 前端构建文件存在"
else
    echo "⚠️  前端构建文件不存在"
    echo "   运行: ./deploy.sh 重新部署"
    echo ""
fi

echo ""
echo "📋 常用命令:"
echo "   - 重新部署: ./deploy.sh"
echo "   - 启动系统: ./start.sh"
echo "   - 停止系统: ./stop.sh"
echo "   - 查看密码: ./show_password.sh"
echo "   - 安装Node.js: ./install_nodejs.sh"
echo ""
echo "📖 详细说明: INSTALL_GUIDE.md" 