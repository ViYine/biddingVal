#!/bin/bash

# 简化Vite迁移脚本
# 解决依赖冲突问题

set -e

echo "🚀 简化Vite迁移脚本"
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
echo "🔍 备份当前配置..."
cd frontend

# 备份当前配置
if [ -f "package.json" ]; then
    cp package.json package.json.backup
    echo "✅ 备份 package.json"
fi

echo ""
echo "📦 清理旧的依赖..."
rm -rf node_modules package-lock.json build

echo ""
echo "📦 使用兼容的Vite配置..."

# 使用兼容的package.json
if [ -f "package-vite-compatible.json" ]; then
    cp package-vite-compatible.json package.json
    echo "✅ 使用兼容的Vite配置"
else
    echo "❌ 未找到兼容的Vite配置文件"
    exit 1
fi

echo ""
echo "📦 安装Vite依赖..."
npm install --legacy-peer-deps

echo ""
echo "🔧 创建Vite配置文件..."
cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  },
  build: {
    outDir: 'build',
    sourcemap: false,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          utils: ['js-sha256']
        }
      }
    }
  }
})
EOF

echo ""
echo "🔧 更新TypeScript配置..."
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,

    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",

    /* Linting */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF

echo ""
echo "🔧 创建Node.js TypeScript配置..."
cat > tsconfig.node.json << 'EOF'
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
EOF

echo ""
echo "🧪 测试构建..."
if npm run build:prod; then
    echo "✅ Vite构建成功"
else
    echo "❌ Vite构建失败，尝试修复..."
    
    # 尝试使用yarn
    if command -v yarn &> /dev/null; then
        echo "📦 尝试使用yarn..."
        rm -rf node_modules package-lock.json
        yarn install
        if yarn build:prod; then
            echo "✅ 使用yarn构建成功"
        else
            echo "❌ yarn构建也失败"
        fi
    else
        echo "📦 安装yarn..."
        npm install -g yarn
        rm -rf node_modules package-lock.json
        yarn install
        if yarn build:prod; then
            echo "✅ 使用yarn构建成功"
        else
            echo "❌ yarn构建也失败"
        fi
    fi
fi

cd ..

echo ""
echo "🎉 简化Vite迁移完成！"
echo ""
echo "📋 新命令："
echo "   - 开发模式: cd frontend && npm run dev"
echo "   - 生产构建: cd frontend && npm run build:prod"
echo "   - 预览构建: cd frontend && npm run preview"
echo ""
echo "📋 下一步操作："
echo "1. 重新运行部署: ./deploy.sh"
echo "2. 或直接启动: ./start.sh" 