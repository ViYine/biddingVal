#!/usr/bin/env python3
import os
import sys

# 添加backend_api目录到Python路径
sys.path.append('backend_api')

# 导入后端模块以触发环境变量加载
import bidding_api

print("=== 环境变量测试 ===")
print(f"API_TOKEN: {os.getenv('API_TOKEN')}")
print(f"DEVICE_ID: {os.getenv('DEVICE_ID')}")
print(f"USER_ID: {os.getenv('USER_ID')}")
print(f"PORT: {os.getenv('PORT')}")
print(f"FLASK_ENV: {os.getenv('FLASK_ENV')}")

# 测试API URL构建
api_token = os.getenv('API_TOKEN')
device_id = os.getenv('DEVICE_ID', 'd66474b3-fd78-3a95-a56d-76e29e765ea3')
user_id = os.getenv('USER_ID', '2675923')

if api_token:
    url = f'https://apphwhq.longhuvip.com/w1/api/index.php?Order=1&a=MorningBiddingList&st=200&c=HomeDingPan&PhoneOSNew=1&DeviceID={device_id}&VerSion=5.20.0.2&Token={api_token}&Index=0&PidType=0&apiv=w41&Type=4&UserID={user_id}'
    print(f"\n=== API URL ===")
    print(url)
    print("\n✅ 环境变量加载成功！")
else:
    print("\n❌ API_TOKEN未设置！") 