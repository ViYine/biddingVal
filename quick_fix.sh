#!/bin/bash

# 快速修复脚本
# 解决常见的前端构建问题

set -e

echo "🔧 快速修复脚本"
echo "================"

# 检查是否在正确的目录
if [ ! -f "frontend/package.json" ]; then
    echo "❌ 请在项目根目录运行此脚本"
    exit 1
fi

echo "📋 当前目录: $(pwd)"
echo "📋 Node.js 版本: $(node --version)"
echo "📋 npm 版本: $(npm --version)"

echo ""
echo "🔍 诊断问题..."

# 检查Node.js版本
NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 16 ]; then
    echo "❌ Node.js版本过低，需要16或更高版本"
    echo "当前版本: $(node --version)"
    exit 1
else
    echo "✅ Node.js版本: $(node --version)"
fi

echo ""
echo "🔧 开始修复..."

cd frontend

# 方法1: 清理并重新安装
echo "📦 方法1: 清理并重新安装依赖..."
rm -rf node_modules package-lock.json
npm cache clean --force
npm install --legacy-peer-deps

# 测试构建
echo "🧪 测试构建..."
if npm run build:prod; then
    echo "✅ 修复成功！"
    cd ..
    echo ""
    echo "🎉 前端构建问题已解决！"
    echo "📋 下一步操作："
    echo "1. 重新运行部署: ./deploy.sh"
    echo "2. 或直接启动: ./start.sh"
    exit 0
fi

echo "⚠️  方法1失败，尝试方法2..."

# 方法2: 使用yarn
echo "📦 方法2: 使用yarn..."
if command -v yarn &> /dev/null; then
    echo "📦 使用yarn重新安装..."
    rm -rf node_modules package-lock.json yarn.lock
    yarn install
    if yarn build; then
        echo "✅ 使用yarn修复成功！"
        cd ..
        echo ""
        echo "🎉 前端构建问题已解决！"
        echo "📋 下一步操作："
        echo "1. 重新运行部署: ./deploy.sh"
        echo "2. 或直接启动: ./start.sh"
        exit 0
    fi
else
    echo "📦 安装yarn..."
    npm install -g yarn
    rm -rf node_modules package-lock.json yarn.lock
    yarn install
    if yarn build; then
        echo "✅ 使用yarn修复成功！"
        cd ..
        echo ""
        echo "🎉 前端构建问题已解决！"
        echo "📋 下一步操作："
        echo "1. 重新运行部署: ./deploy.sh"
        echo "2. 或直接启动: ./start.sh"
        exit 0
    fi
fi

echo "⚠️  方法2失败，尝试方法3..."

# 方法3: 降级依赖版本
echo "📦 方法3: 降级依赖版本..."
rm -rf node_modules package-lock.json

# 创建临时package.json
cat > package.json.tmp << 'EOF'
{
  "name": "stock-data-frontend",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "@types/node": "^16.18.0",
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "js-sha256": "^0.11.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-flip-toolkit": "^2.0.3",
    "react-scripts": "5.0.1",
    "typescript": "^4.9.0",
    "web-vitals": "^2.1.0"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject",
    "build:prod": "GENERATE_SOURCEMAP=false react-scripts build"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  },
  "proxy": "http://localhost:5000"
}
EOF

mv package.json.tmp package.json
npm install --legacy-peer-deps

if npm run build:prod; then
    echo "✅ 降级依赖修复成功！"
    cd ..
    echo ""
    echo "🎉 前端构建问题已解决！"
    echo "📋 下一步操作："
    echo "1. 重新运行部署: ./deploy.sh"
    echo "2. 或直接启动: ./start.sh"
    exit 0
fi

echo "❌ 所有修复方法都失败了"
echo ""
echo "🔧 建议尝试以下方法："
echo "1. 运行详细修复脚本: ./fix_frontend.sh"
echo "2. 迁移到Vite: ./migrate_to_vite.sh"
echo "3. 手动检查错误信息并修复"

cd ..
exit 1 