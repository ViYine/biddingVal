# 多阶段构建
FROM node:18-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci --only=production
COPY frontend/ ./
RUN npm run build:prod

FROM python:3.9-slim
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 复制后端代码
COPY backend_api/ ./backend_api/
WORKDIR /app/backend_api

# 安装Python依赖
RUN pip install --no-cache-dir -r requirements.txt

# 生成随机密码
RUN python3 password_generator.py

# 复制前端构建文件
COPY --from=frontend-builder /app/frontend/build ../frontend/build

# 暴露端口
EXPOSE 5000

# 启动命令
CMD ["gunicorn", "-c", "gunicorn.conf.py", "bidding_api:app"]
