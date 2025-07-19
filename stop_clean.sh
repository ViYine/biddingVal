#!/bin/bash

# 简洁的停止脚本
# 停止所有相关服务

echo "🛑 停止服务"
echo "=========="

echo "📋 当前目录: $(pwd)"

echo ""
echo "🔍 查找并停止Python进程..."

# 停止所有Python进程
pkill -f "python.*bidding_api.py" || true
pkill -f "gunicorn" || true

echo "⏳ 等待进程停止..."
sleep 2

# 检查是否还有进程在运行
if pgrep -f "python.*bidding_api.py" > /dev/null; then
    echo "⚠️ 强制停止进程..."
    pkill -9 -f "python.*bidding_api.py" || true
fi

echo ""
echo "🔍 检查端口占用..."
if lsof -Pi :5000 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️ 端口5000仍被占用，尝试强制释放..."
    lsof -ti:5000 | xargs kill -9 || true
else
    echo "✅ 端口5000已释放"
fi

echo ""
echo "🎉 服务已停止！"
echo ""
echo "📋 常用命令："
echo "- 启动服务: ./start_clean.sh"
echo "- 重新部署: ./deploy_clean.sh" 