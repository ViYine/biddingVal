from flask import Flask, jsonify, request, Response, send_from_directory
import pandas as pd
import os
import glob
import re
import json
import logging
from datetime import datetime
from password_generator import get_password_hash

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 加载环境变量
def load_env_file():
    """加载.env文件中的环境变量"""
    try:
        # 获取当前文件所在目录
        current_dir = os.path.dirname(os.path.abspath(__file__))
        env_file = os.path.join(os.path.dirname(current_dir), '.env')
        if os.path.exists(env_file):
            with open(env_file, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#') and '=' in line:
                        key, value = line.split('=', 1)
                        os.environ[key.strip()] = value.strip()
            logger.info(f"环境变量文件加载成功: {env_file}")
        else:
            logger.warning(f"环境变量文件不存在: {env_file}")
    except Exception as e:
        logger.error(f"加载环境变量文件失败: {e}")

# 加载环境变量
load_env_file()

app = Flask(__name__)

# 生产环境配置
app.config['JSON_AS_ASCII'] = False
app.config['JSONIFY_PRETTYPRINT_REGULAR'] = False

# 允许跨域请求
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response

import requests
from flask import jsonify

@app.route('/api/realtime_limit')
def proxy_realtime_limit():
    """代理实时数据API"""
    try:
        # 从环境变量获取API配置，如果没有则使用默认值
        api_token = os.getenv('API_TOKEN')
        if not api_token:
            logger.error("API_TOKEN环境变量未设置")
            return jsonify({'error': 'API配置错误', 'data': []}), 500
        device_id = os.getenv('DEVICE_ID', 'd66474b3-fd78-3a95-a56d-76e29e765ea3')
        user_id = os.getenv('USER_ID', '2675923')
        
        url = f'https://apphwhq.longhuvip.com/w1/api/index.php?Order=1&a=MorningBiddingList&st=200&c=HomeDingPan&PhoneOSNew=1&DeviceID={device_id}&VerSion=5.20.0.2&Token={api_token}&Index=0&PidType=0&apiv=w41&Type=4&UserID={user_id}'
        resp = requests.get(url, timeout=5)
        resp.raise_for_status()
        return jsonify(resp.json())
    except requests.RequestException as e:
        logger.error(f"实时数据API请求失败: {e}")
        return jsonify({'error': '实时数据获取失败', 'data': []}), 500
    except Exception as e:
        logger.error(f"实时数据处理失败: {e}")
        return jsonify({'error': '数据处理失败', 'data': []}), 500

@app.route('/api/bidding')
def get_bidding():
    """获取历史竞价数据"""
    try:
        date = request.args.get('date')  # 例如 '2025-07-18'
        start = request.args.get('start')  # 例如 '091500'
        end = request.args.get('end')      # 例如 '092500'
        
        if not date or not start or not end:
            return jsonify({'error': '参数缺失'}), 400

        # 匹配所有该日期的csv文件
        pattern = f'copy_bidding/bidding_{date}_*_limit.csv'
        files = glob.glob(pattern)
        
        if not files:
            return jsonify({'error': f'未找到日期 {date} 的数据文件'}), 404
        
        # 提取时间字符串并排序
        file_time_pairs = []
        for f in files:
            m = re.search(rf'bidding_{date}_(\d{{4,6}})_limit\.csv', f)
            if m:
                tstr = m.group(1)
                # 补全为6位（如0915 -> 091500）
                if len(tstr) == 4:
                    tstr += '00'
                file_time_pairs.append((tstr, f))
        
        # 过滤时间段
        file_time_pairs = [p for p in file_time_pairs if start <= p[0] <= end]
        file_time_pairs.sort()

        if not file_time_pairs:
            return jsonify({'error': f'在时间段 {start}-{end} 内未找到数据'}), 404

        result = {}
        for tstr, fpath in file_time_pairs:
            try:
                df = pd.read_csv(fpath, dtype=str)  # 全部读为字符串
                df = df.replace({pd.NA: None, '': None, 'nan': None, 'NaN': None})
                data = df.where(pd.notnull(df), None).values.tolist()
                result[tstr] = data
            except Exception as e:
                logger.error(f"读取文件 {fpath} 失败: {e}")
                continue
        
        sorted_times = [t for t, _ in file_time_pairs]
        
        # 用 json.dumps 并设置 ensure_ascii=False
        resp = json.dumps({'timestamps': sorted_times, 'data': result}, ensure_ascii=False)
        return Response(resp, content_type='application/json; charset=utf-8')
        
    except Exception as e:
        logger.error(f"获取历史数据失败: {e}")
        return jsonify({'error': '服务器内部错误'}), 500

@app.route('/api/password')
def get_password():
    """获取当前密码信息（仅用于部署时显示）"""
    try:
        password_file = os.path.join(os.path.dirname(__file__), 'password.json')
        if os.path.exists(password_file):
            with open(password_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                return jsonify({
                    'password': data.get('password'),
                    'generated_at': data.get('generated_at')
                })
        else:
            return jsonify({'error': '密码文件不存在'}), 404
    except Exception as e:
        logger.error(f"获取密码信息失败: {e}")
        return jsonify({'error': '获取密码信息失败'}), 500

@app.route('/api/password_hash')
def get_password_hash_api():
    """获取密码哈希值（用于前端验证）"""
    try:
        password_hash = get_password_hash()
        if password_hash:
            return jsonify({'hash': password_hash})
        else:
            return jsonify({'error': '密码哈希不存在'}), 404
    except Exception as e:
        logger.error(f"获取密码哈希失败: {e}")
        return jsonify({'error': '获取密码哈希失败'}), 500

@app.route('/api/health')
def health_check():
    """健康检查接口"""
    return jsonify({
        'status': 'ok',
        'timestamp': datetime.now().isoformat(),
        'service': 'stock-data-api'
    })

# 生产环境静态文件服务
@app.route('/')
def serve_frontend():
    """服务前端静态文件"""
    # 获取当前文件所在目录，然后找到frontend/build
    current_dir = os.path.dirname(os.path.abspath(__file__))
    frontend_build_dir = os.path.join(os.path.dirname(current_dir), 'frontend', 'build')
    return send_from_directory(frontend_build_dir, 'index.html')

@app.route('/static/js/<path:filename>')
def serve_js_files(filename):
    """服务JavaScript文件"""
    # 获取当前文件所在目录，然后找到frontend/build
    current_dir = os.path.dirname(os.path.abspath(__file__))
    frontend_build_dir = os.path.join(os.path.dirname(current_dir), 'frontend', 'build')
    
    # 添加调试日志
    logger.info(f"请求JS文件: static/js/{filename}")
    logger.info(f"静态文件目录: {frontend_build_dir}")
    
    # 检查文件是否存在
    file_path = os.path.join(frontend_build_dir, 'static', 'js', filename)
    if os.path.exists(file_path):
        logger.info(f"文件存在: {file_path}")
        return send_from_directory(os.path.join(frontend_build_dir, 'static', 'js'), filename)
    else:
        logger.warning(f"文件不存在: {file_path}")
        return jsonify({'error': 'JS文件不存在'}), 404

@app.route('/static/<path:path>')
def serve_static_files(path):
    """服务其他静态资源文件"""
    # 获取当前文件所在目录，然后找到frontend/build
    current_dir = os.path.dirname(os.path.abspath(__file__))
    frontend_build_dir = os.path.join(os.path.dirname(current_dir), 'frontend', 'build')
    
    # 添加调试日志
    logger.info(f"请求静态文件: static/{path}")
    logger.info(f"静态文件目录: {frontend_build_dir}")
    
    # 检查文件是否存在
    file_path = os.path.join(frontend_build_dir, 'static', path)
    if os.path.exists(file_path):
        logger.info(f"文件存在: {file_path}")
        return send_from_directory(os.path.join(frontend_build_dir, 'static'), path)
    else:
        logger.warning(f"文件不存在: {file_path}")
        return jsonify({'error': '静态文件不存在'}), 404

@app.route('/<path:path>')
def serve_static(path):
    """服务其他静态资源"""
    # 获取当前文件所在目录，然后找到frontend/build
    current_dir = os.path.dirname(os.path.abspath(__file__))
    frontend_build_dir = os.path.join(os.path.dirname(current_dir), 'frontend', 'build')
    
    # 添加调试日志
    logger.info(f"请求其他静态文件: {path}")
    logger.info(f"静态文件目录: {frontend_build_dir}")
    
    # 检查文件是否存在
    file_path = os.path.join(frontend_build_dir, path)
    if os.path.exists(file_path):
        logger.info(f"文件存在: {file_path}")
        return send_from_directory(frontend_build_dir, path)
    else:
        logger.warning(f"文件不存在: {file_path}")
        # 如果文件不存在，尝试返回index.html（用于SPA路由）
        if not path.startswith('api/'):
            logger.info(f"返回index.html用于SPA路由")
            return send_from_directory(frontend_build_dir, 'index.html')
        else:
            return jsonify({'error': '文件不存在'}), 404

if __name__ == '__main__':
    # 开发环境
    app.run(host='0.0.0.0', port=5001, debug=True)
