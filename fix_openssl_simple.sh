#!/bin/bash

# 简单的OpenSSL修复脚本
# 只修改构建命令，不改变依赖

set -e

echo "🔧 简单OpenSSL修复"
echo "=================="

# 检查是否在正确的目录
if [ ! -f "frontend/package.json" ]; then
    echo "❌ 请在项目根目录运行此脚本"
    exit 1
fi

echo "📋 当前目录: $(pwd)"
echo "📋 Node.js 版本: $(node --version)"

echo ""
echo "🔍 检查前端目录..."
cd frontend

# 备份当前配置
if [ -f "package.json" ]; then
    cp package.json package.json.backup
    echo "✅ 备份 package.json"
fi

echo ""
echo "🔧 修改构建命令以支持Node.js 18 OpenSSL..."

# 使用sed修改package.json中的构建命令
if command -v sed &> /dev/null; then
    # 修改start命令
    sed -i 's/"start": "react-scripts start"/"start": "NODE_OPTIONS=\"--openssl-legacy-provider\" react-scripts start"/g' package.json
    
    # 修改build命令
    sed -i 's/"build": "react-scripts build"/"build": "NODE_OPTIONS=\"--openssl-legacy-provider\" react-scripts build"/g' package.json
    
    # 修改build:prod命令（如果存在）
    sed -i 's/"build:prod": "GENERATE_SOURCEMAP=false react-scripts build"/"build:prod": "NODE_OPTIONS=\"--openssl-legacy-provider\" GENERATE_SOURCEMAP=false react-scripts build"/g' package.json
    
    # 如果没有build:prod命令，添加一个
    if ! grep -q '"build:prod"' package.json; then
        # 在scripts部分添加build:prod命令
        sed -i '/"build":/a\    "build:prod": "NODE_OPTIONS=\"--openssl-legacy-provider\" GENERATE_SOURCEMAP=false react-scripts build",' package.json
    fi
    
    echo "✅ 修改完成"
else
    echo "❌ sed命令不可用，手动修改package.json"
    echo "请在package.json的scripts部分添加NODE_OPTIONS='--openssl-legacy-provider'"
    exit 1
fi

echo ""
echo "🧪 测试构建..."
if npm run build:prod; then
    echo "✅ 构建成功"
else
    echo "❌ npm构建失败，尝试使用yarn..."
    
    if command -v yarn &> /dev/null; then
        if yarn build:prod; then
            echo "✅ 使用yarn构建成功"
        else
            echo "❌ yarn构建也失败"
            exit 1
        fi
    else
        echo "❌ yarn不可用"
        exit 1
    fi
fi

cd ..

echo ""
echo "🎉 简单OpenSSL修复完成！"
echo ""
echo "📋 下一步操作："
echo "1. 重新运行部署: ./deploy.sh"
echo "2. 或直接启动: ./start.sh" 