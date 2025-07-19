# Gunicorn配置文件
bind = "0.0.0.0:5001"
workers = 1
worker_class = "sync"
timeout = 30
keepalive = 2
preload_app = False
reload = False
accesslog = "-"
errorlog = "-"
loglevel = "info" 