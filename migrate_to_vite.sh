#!/bin/bash

# 前端迁移到Vite脚本
# 解决Create React App的依赖问题

set -e

echo "🚀 前端迁移到Vite"
echo "=================="

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

if [ -f "tsconfig.json" ]; then
    cp tsconfig.json tsconfig.json.backup
    echo "✅ 备份 tsconfig.json"
fi

echo ""
echo "📦 清理旧的依赖..."
rm -rf node_modules package-lock.json build

echo ""
echo "📦 迁移到Vite..."

# 使用Vite的package.json
if [ -f "package-vite.json" ]; then
    cp package-vite.json package.json
    echo "✅ 使用Vite配置"
else
    echo "❌ 未找到Vite配置文件"
    exit 1
fi

echo ""
echo "📦 安装Vite依赖..."
npm install

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
echo "🔧 创建ESLint配置..."
cat > .eslintrc.cjs << 'EOF'
module.exports = {
  root: true,
  env: { browser: true, es2020: true },
  extends: [
    'eslint:recommended',
    '@typescript-eslint/recommended',
    'plugin:react-hooks/recommended',
  ],
  ignorePatterns: ['dist', '.eslintrc.cjs'],
  parser: '@typescript-eslint/parser',
  plugins: ['react-refresh'],
  rules: {
    'react-refresh/only-export-components': [
      'warn',
      { allowConstantExport: true },
    ],
  },
}
EOF

echo ""
echo "🧪 测试构建..."
if npm run build:prod; then
    echo "✅ Vite构建成功"
else
    echo "❌ Vite构建失败"
    echo ""
    echo "🔧 尝试修复..."
    
    # 检查是否有TypeScript错误
    echo "🔍 检查TypeScript错误..."
    npx tsc --noEmit || echo "⚠️  TypeScript检查失败，继续..."
    
    # 尝试简单构建
    echo "📦 尝试简单构建..."
    npm run build
fi

cd ..

echo ""
echo "🎉 前端迁移到Vite完成！"
echo ""
echo "📋 新命令："
echo "   - 开发模式: cd frontend && npm run dev"
echo "   - 生产构建: cd frontend && npm run build:prod"
echo "   - 预览构建: cd frontend && npm run preview"
echo ""
echo "📋 下一步操作："
echo "1. 重新运行部署: ./deploy.sh"
echo "2. 或直接启动: ./start.sh" 