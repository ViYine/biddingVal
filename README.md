# 股票数据可视化系统

一个完整的股票竞价数据可视化系统，支持实时数据展示和历史数据回放功能。

## ⚠️ 安全提醒

**在推送到Git之前，请确保：**
- 已创建 `.gitignore` 文件并正确配置
- 敏感文件（如 `password.json`）已被排除
- API Token等敏感信息已移至环境变量
- 数据库文件不会被提交
- 虚拟环境和构建文件已被排除

## 功能特性

- 🔐 **安全登录**: 随机密码生成，支持会话持久化
- 📊 **实时数据**: 9:15-9:25期间自动获取实时竞价数据
- 📈 **动态图表**: 前20名股票封单额动态排名展示
- 🎬 **历史回放**: 支持历史数据时间轴播放和手动控制
- 📱 **响应式设计**: 适配桌面和移动设备
- 🌐 **LAN访问**: 支持局域网访问

## 技术栈

### 前端
- React 18 + TypeScript
- react-flip-toolkit (动画效果)
- js-sha256 (密码加密)
- 响应式设计

### 后端
- Python Flask
- Pandas (数据处理)
- Gunicorn (生产服务器)
- SQLite (数据存储)

## 快速开始

### 系统要求
- Python 3.8+
- Node.js 16+
- npm 或 yarn

### Git推送安全检查

在推送到Git之前，请运行以下命令确保安全：

```bash
# 检查敏感文件是否被正确排除
git status

# 检查是否有敏感信息泄露
grep -r "password\|token\|secret\|key" . --exclude-dir=node_modules --exclude-dir=venv --exclude-dir=__pycache__

# 确保.gitignore文件存在
ls -la .gitignore
```

**重要提醒：**
- `password.json` 文件包含实际密码，不应提交到Git
- API Token已移至环境变量，但请确保 `.env` 文件不被提交
- 数据库文件（`*.db`）不应提交
- 虚拟环境目录（`venv/`）不应提交

### 一键部署

1. **克隆项目**
```bash
git clone <repository-url>
cd stock_data_project
```

2. **运行部署脚本**
```bash
chmod +x deploy.sh
./deploy.sh
```

3. **启动服务**
```bash
./start.sh
```

4. **访问应用**
- 地址: http://localhost:5000
- 密码: 部署时自动生成并显示在控制台

### Docker部署

```bash
# 构建并启动
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

## 项目结构

```
stock_data_project/
├── backend_api/              # 后端API服务
│   ├── copy_bidding/         # CSV数据文件目录
│   ├── venv/                # Python虚拟环境
│   ├── password.json        # 随机生成的密码文件
│   ├── password_generator.py # 密码生成器
│   ├── bidding_api.py       # 主API文件
│   ├── requirements.txt     # Python依赖
│   └── gunicorn.conf.py     # Gunicorn配置
├── frontend/                # 前端React应用
│   ├── build/               # 生产构建文件
│   ├── src/                 # 源代码
│   │   ├── components/      # React组件
│   │   └── App.tsx         # 主应用组件
│   └── package.json        # Node.js依赖
├── deploy.sh               # 一键部署脚本
├── start.sh                # 启动脚本
├── stop.sh                 # 停止脚本
├── show_password.sh        # 密码查看脚本
├── Dockerfile              # Docker配置
└── docker-compose.yml      # Docker Compose配置
```

## API接口

### 实时数据
- `GET /api/realtime_limit` - 获取实时竞价数据

### 历史数据
- `GET /api/bidding?date=2025-07-18&start=091500&end=092500` - 获取历史数据

### 密码管理
- `GET /api/password` - 获取当前密码信息
- `GET /api/password_hash` - 获取密码哈希值

### 健康检查
- `GET /api/health` - 服务健康状态

## 密码系统

### 随机密码生成
- 每次部署时自动生成8位随机密码
- 密码包含字母和数字
- 密码哈希值用于前端验证
- 密码信息保存在 `backend_api/password.json` 文件中

### 密码管理命令
```bash
# 查看当前密码
./show_password.sh

# 重新生成密码
cd stock_data_project/backend_api
python3 password_generator.py
```

## 数据格式

CSV文件应包含以下列：
1. `code` - 股票代码
2. `name` - 股票名称
3. `现价` - 当前价格
4. `涨幅` - 涨跌幅
5. `涨停封单额` - 封单金额
6. `开盘涨幅` - 开盘涨跌幅
7. `竞价净额` - 竞价净额
8. `竞价换手` - 竞价换手率
9. `竞价成交额` - 竞价成交额
10. `未知` - 未知字段
11. `开盘金额` - 开盘金额
12. `板块` - 所属板块

## 配置说明

### 环境变量
- `FLASK_ENV` - Flask环境 (development/production)
- `PORT` - 服务端口 (默认5000)

### 前端配置
- 生产环境API地址自动适配
- 支持代理配置避免CORS问题
- 动态密码验证

### 后端配置
- Gunicorn多进程配置
- 自动CORS处理
- 错误日志记录
- 随机密码生成

## 开发指南

### 本地开发

1. **启动后端**
```bash
cd backend_api
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python bidding_api.py
```

2. **启动前端**
```bash
cd frontend
npm install
npm start
```

### 生产部署

1. **构建前端**
```bash
cd frontend
npm run build:prod
```

2. **启动后端**
```bash
cd backend_api
gunicorn -c gunicorn.conf.py bidding_api:app
```

## 故障排除

### 常见问题

1. **端口被占用**
```bash
# 查找占用进程
lsof -i :5000
# 杀死进程
kill -9 <PID>
```

2. **数据文件不存在**
- 确保CSV文件放在 `backend_api/copy_bidding/` 目录下
- 文件名格式: `bidding_YYYY-MM-DD_HHMM_limit.csv`

3. **前端构建失败**
```bash
# 清理缓存
rm -rf node_modules package-lock.json
npm install
```

4. **Python依赖问题**
```bash
# 重新创建虚拟环境
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

5. **密码问题**
```bash
# 重新生成密码
cd backend_api
python3 password_generator.py
```

### 日志查看

```bash
# 查看后端日志
tail -f backend_api/logs/app.log

# 查看Docker日志
docker-compose logs -f
```

## 安全说明

- 密码使用SHA256哈希存储
- 前端不直接获取明文密码
- 密码文件仅用于部署时显示
- 支持会话过期机制

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request！

## 更新日志

### v1.1.0
- 添加随机密码生成功能
- 每次部署自动生成新密码
- 密码信息显示在控制台
- 增强安全性

### v1.0.0
- 初始版本发布
- 支持实时和历史数据展示
- 添加登录验证和视频录制功能
- 完成生产环境部署配置 