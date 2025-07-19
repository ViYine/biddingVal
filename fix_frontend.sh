#!/bin/bash

# 前端依赖修复脚本
# 解决 ajv 模块和其他依赖问题

set -e

echo "🔧 前端依赖修复脚本"
echo "===================="

# 检查是否在正确的目录
if [ ! -f "frontend/package.json" ]; then
    echo "❌ 请在项目根目录运行此脚本"
    exit 1
fi

echo "📋 当前目录: $(pwd)"
echo "📋 Node.js 版本: $(node --version)"
echo "📋 npm 版本: $(npm --version)"

echo ""
echo "🔍 检查前端目录..."
cd frontend

# 清理旧的依赖
echo "🧹 清理旧的依赖..."
rm -rf node_modules package-lock.json

# 清理npm缓存
echo "🧹 清理npm缓存..."
npm cache clean --force

# 安装ajv相关依赖
echo "📦 安装ajv相关依赖..."
npm install ajv@^8.0.0 --save-dev

# 重新安装所有依赖
echo "📦 重新安装所有依赖..."
npm install

# 检查是否有其他冲突的依赖
echo "🔍 检查依赖冲突..."
npm ls ajv 2>/dev/null || echo "⚠️  ajv 依赖检查失败，继续..."

# 尝试修复依赖
echo "🔧 尝试修复依赖..."
npm audit fix --force

echo ""
echo "🔍 验证安装..."
if npm ls react-scripts > /dev/null 2>&1; then
    echo "✅ react-scripts 安装成功"
else
    echo "❌ react-scripts 安装失败"
fi

if npm ls ajv > /dev/null 2>&1; then
    echo "✅ ajv 安装成功"
else
    echo "❌ ajv 安装失败"
fi

echo ""
echo "🧪 测试构建..."
if npm run build:prod; then
    echo "✅ 构建测试成功"
else
    echo "❌ 构建测试失败，尝试其他解决方案..."
    
    # 尝试使用yarn
    if command -v yarn &> /dev/null; then
        echo "📦 尝试使用yarn..."
        rm -rf node_modules package-lock.json
        yarn install
        yarn build
    else
        echo "📦 安装yarn..."
        npm install -g yarn
        rm -rf node_modules package-lock.json
        yarn install
        yarn build
    fi
fi

cd ..

echo ""
echo "🎉 前端依赖修复完成！"
echo ""
echo "📋 下一步操作："
echo "1. 重新运行部署: ./deploy.sh"
echo "2. 或直接启动: ./start.sh" 