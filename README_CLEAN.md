# 简洁部署脚本

这是一套简洁的部署脚本，不包含复杂的修复逻辑，只做基本的部署工作。

## 脚本说明

### 1. `deploy_clean.sh` - 完整部署
- 安装后端Python依赖
- 安装前端Node.js依赖
- 构建前端生产版本
- 启动后端服务

### 2. `start_clean.sh` - 启动服务
- 检查环境是否已准备
- 启动后端服务

### 3. `stop_clean.sh` - 停止服务
- 停止所有相关进程
- 释放端口

## 使用方法

### 首次部署
```bash
chmod +x deploy_clean.sh
./deploy_clean.sh
```

### 日常使用
```bash
# 启动服务
chmod +x start_clean.sh
./start_clean.sh

# 停止服务
chmod +x stop_clean.sh
./stop_clean.sh
```

## 服务信息

- **后端API**: http://localhost:5000
- **前端应用**: http://localhost:5000 (通过后端代理)

## 常用命令

```bash
# 停止服务
pkill -f "python.*bidding_api.py"

# 查看日志
tail -f backend_api/app.log

# 检查端口占用
lsof -i :5000
```

## 注意事项

1. 确保已安装Python 3.x和Node.js
2. 如果遇到问题，请检查错误信息并手动解决
3. 这些脚本不包含自动修复逻辑，需要手动处理问题 