#!/bin/bash

# 简洁纯粹的部署脚本
# 只做基本的部署，不包含复杂修复逻辑

set -e

echo "🚀 开始部署"
echo "=========="

# 检查是否在正确的目录
if [ ! -f "backend_api/bidding_api.py" ]; then
    echo "❌ 请在项目根目录运行此脚本"
    exit 1
fi

echo "📋 当前目录: $(pwd)"
echo "📋 Python 版本: $(python3 --version)"
echo "📋 Node.js 版本: $(node --version)"

echo ""
echo "🔧 检查并安装后端依赖..."
cd backend_api

# 检查虚拟环境
if [ ! -d "venv" ]; then
    echo "📦 创建Python虚拟环境..."
    python3 -m venv venv
fi

echo "📦 激活虚拟环境并安装依赖..."
source venv/bin/activate
pip install -r requirements.txt

echo ""
echo "🔧 检查并安装前端依赖..."
cd ../frontend

# 检查Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 未找到Node.js，请先安装Node.js"
    exit 1
fi

# 检查npm
if ! command -v npm &> /dev/null; then
    echo "❌ 未找到npm，请先安装npm"
    exit 1
fi

echo "📦 安装前端依赖..."
npm install

echo ""
echo "🏗️ 构建前端生产版本..."
npm run build

cd ..

echo ""
echo "🚀 启动后端服务..."
cd backend_api
source venv/bin/activate

# 检查端口是否被占用
if lsof -Pi :5000 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️ 端口5000已被占用，尝试停止现有进程..."
    pkill -f "python.*bidding_api.py" || true
    sleep 2
fi

echo "🎯 启动Flask应用..."
python bidding_api.py &

# 等待后端启动
echo "⏳ 等待后端服务启动..."
sleep 5

# 检查后端是否启动成功
if curl -s http://localhost:5000/health > /dev/null; then
    echo "✅ 后端服务启动成功"
else
    echo "❌ 后端服务启动失败"
    exit 1
fi

cd ..

echo ""
echo "🎉 部署完成！"
echo ""
echo "📋 服务信息："
echo "- 后端API: http://localhost:5000"
echo "- 前端应用: http://localhost:5000 (通过后端代理)"
echo ""
echo "📋 常用命令："
echo "- 停止服务: pkill -f 'python.*bidding_api.py'"
echo "- 查看日志: tail -f backend_api/app.log"
echo "- 重启服务: ./deploy_clean.sh" 