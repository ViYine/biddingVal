#!/bin/bash

# 股票数据可视化系统简化部署脚本

set -e

echo "🚀 股票数据可视化系统简化部署"
echo "=============================="

# 检查是否在正确的目录
if [ ! -f "backend_api/bidding_api.py" ]; then
    echo "❌ 请在项目根目录运行此脚本"
    exit 1
fi

echo "📋 当前目录: $(pwd)"

# 检测操作系统
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    echo "📋 检测到操作系统: Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    echo "📋 检测到操作系统: macOS"
else
    echo "📋 检测到操作系统: $OSTYPE"
fi

echo ""
echo "🔍 检查系统依赖..."

# 检查Python3
if ! command -v python3 &> /dev/null; then
    echo "❌ 未找到 python3，请先安装"
    exit 1
else
    echo "✅ python3 已安装"
fi

# 检查pip3
if ! command -v pip3 &> /dev/null; then
    echo "❌ 未找到 pip3，请先安装"
    exit 1
else
    echo "✅ pip3 已安装"
fi

# 检查Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 未找到 node，请先安装"
    echo "运行: ./install_nodejs.sh 或 ./install_centos.sh"
    exit 1
else
    echo "✅ node 已安装"
fi

# 检查npm
if ! command -v npm &> /dev/null; then
    echo "❌ 未找到 npm，请先安装"
    exit 1
else
    echo "✅ npm 已安装"
fi

echo ""
echo "🔧 部署后端API..."

# 进入后端目录
cd backend_api

# 创建虚拟环境
echo "📦 创建Python虚拟环境..."
python3 -m venv venv

# 激活虚拟环境
echo "🔌 激活虚拟环境..."
source venv/bin/activate

# 升级pip
echo "📦 升级pip..."
pip install --upgrade pip

# 安装Python依赖
echo "📥 安装Python依赖..."
pip install -r requirements.txt

# 生成随机密码
echo "🔐 生成随机密码..."
python3 password_generator.py

# 读取密码
PASSWORD=$(python3 -c "import json; print(json.load(open('password.json'))['password'])")

cd ..

echo ""
echo "🎨 部署前端应用..."

# 进入前端目录
cd frontend

# 清理旧的依赖
echo "🧹 清理旧的依赖..."
rm -rf node_modules package-lock.json

# 安装依赖
echo "📥 安装Node.js依赖..."
npm install --legacy-peer-deps

# 构建生产版本
echo "🏗️  构建前端生产版本..."
if npm run build:prod; then
    echo "✅ 前端构建成功"
else
    echo "❌ 前端构建失败，尝试修复..."
    
    # 尝试修复
    echo "🔧 尝试修复前端问题..."
    cd ..
    
    if [ -f "fix_simple_cra.sh" ]; then
        echo "📦 运行最简单的Create React App 3.x修复脚本..."
        chmod +x fix_simple_cra.sh
        ./fix_simple_cra.sh
    elif [ -f "fix_ajv_deep.sh" ]; then
        echo "📦 运行深度ajv修复脚本..."
        chmod +x fix_ajv_deep.sh
        ./fix_ajv_deep.sh
    elif [ -f "fix_ajv_conflict.sh" ]; then
        echo "📦 运行ajv冲突修复脚本..."
        chmod +x fix_ajv_conflict.sh
        ./fix_ajv_conflict.sh
    elif [ -f "fix_cra4.sh" ]; then
        echo "📦 运行Create React App 4.x修复脚本..."
        chmod +x fix_cra4.sh
        ./fix_cra4.sh
    elif [ -f "fix_npm_packages.sh" ]; then
        echo "📦 运行npm包修复脚本..."
        chmod +x fix_npm_packages.sh
        ./fix_npm_packages.sh
    elif [ -f "fix_cra.sh" ]; then
        echo "📦 运行Create React App修复脚本..."
        chmod +x fix_cra.sh
        ./fix_cra.sh
    elif [ -f "quick_fix.sh" ]; then
        echo "📦 运行快速修复脚本..."
        chmod +x quick_fix.sh
        ./quick_fix.sh
    else
        echo "❌ 无法找到修复脚本"
        echo "请手动修复前端构建问题"
        exit 1
    fi
    
    cd frontend
fi

cd ..

echo ""
echo "📝 创建启动脚本..."

# 创建启动脚本
cat > start.sh << 'EOF'
#!/bin/bash

# 股票数据可视化系统启动脚本

echo "🚀 启动股票数据可视化系统..."

# 读取当前密码
if [ -f "backend_api/password.json" ]; then
    PASSWORD=$(python3 -c "import json; print(json.load(open('backend_api/password.json'))['password'])")
    echo "🔐 当前登录密码: $PASSWORD"
else
    echo "❌ 密码文件不存在"
    exit 1
fi

# 启动后端服务
echo "🔧 启动后端服务..."
cd backend_api

# 检查虚拟环境
if [ ! -d "venv" ]; then
    echo "❌ 虚拟环境不存在，请先运行 ./deploy.sh"
    exit 1
fi

# 激活虚拟环境
echo "🔌 激活虚拟环境..."
source venv/bin/activate

# 使用Gunicorn启动生产服务
echo "🌐 启动API服务器 (端口: 5001)..."
gunicorn -c gunicorn.conf.py bidding_api:app &
BACKEND_PID=$!
echo "✅ 后端服务已启动 (PID: $BACKEND_PID)"

# 等待后端启动
echo "⏳ 等待服务启动..."
for i in {1..10}; do
    if curl -f http://localhost:5001/api/health > /dev/null 2>&1; then
        echo "✅ 后端服务运行正常"
        break
    fi
    if [ $i -eq 10 ]; then
        echo "❌ 后端服务启动失败"
        kill $BACKEND_PID 2>/dev/null || true
        exit 1
    fi
    sleep 1
done

echo ""
echo "🎉 股票数据可视化系统启动成功!"
echo "📊 访问地址: http://localhost:5001"
echo "🔑 登录密码: $PASSWORD"
echo ""
echo "按 Ctrl+C 停止服务"

# 等待用户中断
wait $BACKEND_PID
EOF

chmod +x start.sh

# 创建停止脚本
cat > stop.sh << 'EOF'
#!/bin/bash

echo "🛑 停止股票数据可视化系统..."

# 停止后端服务
pkill -f "gunicorn.*bidding_api:app" || true

echo "✅ 服务已停止"
EOF

chmod +x stop.sh

# 创建密码查看脚本
cat > show_password.sh << 'EOF'
#!/bin/bash

echo "🔐 查看当前登录密码..."

if [ -f "backend_api/password.json" ]; then
    PASSWORD=$(python3 -c "import json; print(json.load(open('backend_api/password.json'))['password'])")
    echo "当前登录密码: $PASSWORD"
else
    echo "❌ 密码文件不存在"
fi
EOF

chmod +x show_password.sh

echo ""
echo "🎉 部署完成!"
echo ""
echo "📋 部署信息:"
echo "   - 后端API: http://localhost:5001"
echo "   - 前端应用: http://localhost:5001"
echo "   - 登录密码: $PASSWORD"
echo ""
echo "🚀 启动方式:"
echo "   1. 直接启动: ./start.sh"
echo "   2. 手动启动: cd backend_api && source venv/bin/activate && gunicorn -c gunicorn.conf.py bidding_api:app"
echo ""
echo "🛑 停止服务: ./stop.sh"
echo "🔐 查看密码: ./show_password.sh"
echo ""
echo "✅ 部署完成，可以开始使用了!"
echo "🔑 请记住您的登录密码: $PASSWORD" 