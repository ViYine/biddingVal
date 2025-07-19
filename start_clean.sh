#!/bin/bash

# 简洁的启动脚本
# 只启动后端服务

set -e

echo "🚀 启动服务"
echo "=========="

# 检查是否在正确的目录
if [ ! -f "backend_api/bidding_api.py" ]; then
    echo "❌ 请在项目根目录运行此脚本"
    exit 1
fi

echo "📋 当前目录: $(pwd)"

echo ""
echo "🔧 检查后端环境..."
cd backend_api

# 检查虚拟环境
if [ ! -d "venv" ]; then
    echo "❌ 虚拟环境不存在，请先运行 ./deploy_clean.sh"
    exit 1
fi

# 检查前端构建
if [ ! -d "../frontend/build" ]; then
    echo "❌ 前端构建不存在，请先运行 ./deploy_clean.sh"
    exit 1
fi

echo "📦 激活虚拟环境..."
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
echo "🎉 服务启动完成！"
echo ""
echo "📋 服务信息："
echo "- 后端API: http://localhost:5000"
echo "- 前端应用: http://localhost:5000 (通过后端代理)"
echo ""
echo "📋 常用命令："
echo "- 停止服务: pkill -f 'python.*bidding_api.py'"
echo "- 查看日志: tail -f backend_api/app.log" 