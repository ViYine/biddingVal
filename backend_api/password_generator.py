import secrets
import string
import hashlib
import json
import os

def generate_password():
    """生成随机密码"""
    # 生成8位随机密码，包含字母和数字
    alphabet = string.ascii_letters + string.digits
    password = ''.join(secrets.choice(alphabet) for _ in range(8))
    return password

def hash_password(password):
    """对密码进行SHA256哈希"""
    return hashlib.sha256(password.encode('utf-8')).hexdigest()

def save_password_info(password, password_hash):
    """保存密码信息到文件"""
    password_info = {
        'password': password,
        'hash': password_hash,
        'generated_at': str(int(os.path.getmtime(__file__)))
    }
    
    # 保存到backend_api目录
    password_file = os.path.join(os.path.dirname(__file__), 'password.json')
    with open(password_file, 'w', encoding='utf-8') as f:
        json.dump(password_info, f, ensure_ascii=False, indent=2)
    
    return password_file

def get_password_hash():
    """获取当前密码哈希值"""
    password_file = os.path.join(os.path.dirname(__file__), 'password.json')
    if os.path.exists(password_file):
        with open(password_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
            return data.get('hash')
    return None

if __name__ == '__main__':
    # 生成新密码
    password = generate_password()
    password_hash = hash_password(password)
    password_file = save_password_info(password, password_hash)
    
    print(f"🔐 新密码已生成: {password}")
    print(f"📁 密码文件: {password_file}")
    print(f"🔒 密码哈希: {password_hash}") 