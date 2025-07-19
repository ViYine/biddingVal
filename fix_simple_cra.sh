#!/bin/bash

# 最简单的Create React App 3.x修复脚本
# 完全避免ajv问题

set -e

echo "🔧 最简单的Create React App 3.x修复"
echo "===================================="

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

# 备份当前配置
if [ -f "package.json" ]; then
    cp package.json package.json.backup
    echo "✅ 备份 package.json"
fi

echo ""
echo "📦 清理旧的依赖..."
rm -rf node_modules package-lock.json yarn.lock build

echo ""
echo "📦 创建最简单的Create React App 3.x配置..."
cat > package.json << 'EOF'
{
  "name": "stock-data-frontend",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "@types/node": "^14.14.0",
    "@types/react": "^16.14.0",
    "@types/react-dom": "^16.9.0",
    "js-sha256": "^0.11.0",
    "react": "^16.14.0",
    "react-dom": "^16.14.0",
    "react-flip-toolkit": "^2.0.3",
    "react-scripts": "3.4.4",
    "typescript": "^4.1.2",
    "web-vitals": "^1.0.1"
  },
  "scripts": {
    "start": "SKIP_PREFLIGHT_CHECK=true react-scripts start",
    "build": "SKIP_PREFLIGHT_CHECK=true react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject",
    "build:prod": "SKIP_PREFLIGHT_CHECK=true GENERATE_SOURCEMAP=false react-scripts build"
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

echo ""
echo "📦 安装依赖..."
npm install --legacy-peer-deps

echo ""
echo "🔧 创建js-sha256类型声明..."
mkdir -p src/types
cat > src/types/js-sha256.d.ts << 'EOF'
declare module 'js-sha256' {
  export function sha256(message: string): string;
  export function sha224(message: string): string;
  export function sha256hmac(key: string, message: string): string;
  export function sha224hmac(key: string, message: string): string;
}
EOF

echo ""
echo "🧪 测试构建..."
if npm run build:prod; then
    echo "✅ Create React App 3.x构建成功"
else
    echo "❌ npm构建失败，尝试使用yarn..."
    
    # 尝试使用yarn
    if command -v yarn &> /dev/null; then
        echo "📦 使用yarn重新安装..."
        rm -rf node_modules package-lock.json yarn.lock
        yarn install
        if yarn build:prod; then
            echo "✅ 使用yarn构建成功"
        else
            echo "❌ yarn构建也失败"
            exit 1
        fi
    else
        echo "📦 安装yarn..."
        npm install -g yarn
        rm -rf node_modules package-lock.json yarn.lock
        yarn install
        if yarn build:prod; then
            echo "✅ 使用yarn构建成功"
        else
            echo "❌ yarn构建也失败"
            exit 1
        fi
    fi
fi

cd ..

echo ""
echo "🎉 最简单的Create React App 3.x修复完成！"
echo ""
echo "📋 下一步操作："
echo "1. 重新运行部署: ./deploy.sh"
echo "2. 或直接启动: ./start.sh" 