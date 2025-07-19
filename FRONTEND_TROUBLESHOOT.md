# 前端故障排除指南

## 常见问题及解决方案

### 1. npm依赖解析错误

**错误信息:**
```
npm error ERESOLVE unable to resolve dependency tree
npm error Found: react@18.3.1
npm error Could not resolve dependency:
```

**解决方案:**

**方法一：使用兼容的依赖版本**
```bash
chmod +x fix_cra.sh
./fix_cra.sh
```

**方法二：使用--legacy-peer-deps**
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps
npm run build:prod
```

**方法三：使用yarn**
```bash
cd frontend
rm -rf node_modules package-lock.json
yarn install
yarn build:prod
```

### 2. ajv模块缺失错误

**错误信息:**
```
Error: Cannot find module 'ajv/dist/compile/codegen'
```

**解决方案:**

**方法一：快速修复**
```bash
chmod +x quick_fix.sh
./quick_fix.sh
```

**方法二：详细修复**
```bash
chmod +x fix_frontend.sh
./fix_frontend.sh
```

**方法三：手动修复**
```bash
cd frontend
rm -rf node_modules package-lock.json
npm cache clean --force
npm install ajv@^8.0.0 --save-dev
npm install --legacy-peer-deps
npm run build:prod
```

### 3. npm包不存在错误

**错误信息:**
```
npm error 404 Not Found - GET https://registry.npmjs.org/@types%2fjs-sha256 - Not found
npm error 404 '@types/js-sha256@^0.9.0' is not in this registry.
```

**解决方案:**

**方法一：使用npm包修复脚本**
```bash
chmod +x fix_npm_packages.sh
./fix_npm_packages.sh
```

**方法二：手动修复**
```bash
cd frontend
rm -rf node_modules package-lock.json
# 编辑package.json，移除@types/js-sha256
npm install --legacy-peer-deps
# 创建类型声明文件
mkdir -p src/types
cat > src/types/js-sha256.d.ts << 'EOF'
declare module 'js-sha256' {
  export function sha256(message: string): string;
  export function sha224(message: string): string;
  export function sha256hmac(key: string, message: string): string;
  export function sha224hmac(key: string, message: string): string;
}
EOF
npm run build:prod
```

### 4. Vite迁移问题

**错误信息:**
```
npm error ERESOLVE unable to resolve dependency tree
```

**解决方案:**

**方法一：使用简化Vite迁移**
```bash
chmod +x migrate_to_vite_simple.sh
./migrate_to_vite_simple.sh
```

**方法二：使用兼容的Vite配置**
```bash
cd frontend
cp package-vite-compatible.json package.json
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps
npm run build:prod
```

### 4. TypeScript编译错误

**错误信息:**
```
TypeScript compilation failed
```

**解决方案:**

**方法一：检查TypeScript版本**
```bash
cd frontend
npm list typescript
npm install typescript@^4.9.0 --save-dev
```

**方法二：更新tsconfig.json**
```bash
cd frontend
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "es6"],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noFallthroughCasesInSwitch": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx"
  },
  "include": ["src"]
}
EOF
```

### 5. 构建文件404错误

**错误信息:**
```
HTTP/1.1 404 NOT FOUND
Server: gunicorn
```

**解决方案:**

**方法一：检查构建文件**
```bash
ls -la frontend/build/
```

**方法二：重新构建**
```bash
cd frontend
npm run build:prod
```

**方法三：检查后端静态文件配置**
```bash
# 检查backend_api/bidding_api.py中的静态文件配置
grep -n "static" backend_api/bidding_api.py
```

## 推荐修复顺序

1. **首先尝试npm包修复:**
   ```bash
   chmod +x fix_npm_packages.sh
   ./fix_npm_packages.sh
   ```

2. **如果失败，尝试快速修复:**
   ```bash
   chmod +x quick_fix.sh
   ./quick_fix.sh
   ```

3. **如果还是有问题，修复Create React App:**
   ```bash
   chmod +x fix_cra.sh
   ./fix_cra.sh
   ```

4. **如果还是有问题，尝试Vite迁移:**
   ```bash
   chmod +x migrate_to_vite_simple.sh
   ./migrate_to_vite_simple.sh
   ```

5. **最后，使用详细修复:**
   ```bash
   chmod +x fix_frontend.sh
   ./fix_frontend.sh
   ```

## 环境要求

- Node.js 16.x 或更高版本
- npm 8.x 或更高版本
- 或者 yarn 1.22.x 或更高版本

## 检查环境

```bash
# 检查Node.js版本
node --version

# 检查npm版本
npm --version

# 检查yarn版本（如果安装）
yarn --version

# 检查系统信息
uname -a
```

## 清理命令

```bash
# 清理npm缓存
npm cache clean --force

# 清理yarn缓存
yarn cache clean

# 删除node_modules
rm -rf node_modules package-lock.json

# 重新安装
npm install --legacy-peer-deps
```

## 调试技巧

1. **查看详细错误信息:**
   ```bash
   npm run build:prod 2>&1 | tee build.log
   ```

2. **检查依赖树:**
   ```bash
   npm ls
   ```

3. **检查过时的包:**
   ```bash
   npm outdated
   ```

4. **运行安全审计:**
   ```bash
   npm audit
   npm audit fix
   ```

## 联系支持

如果遇到其他问题，请提供以下信息：
- Node.js版本: `node --version`
- npm版本: `npm --version`
- 操作系统信息: `uname -a`
- 错误日志
- package.json内容 