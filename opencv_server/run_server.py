from main import app
from gevent import pywsgi
from dotenv import load_dotenv
import os

load_dotenv()

PORT = int(os.getenv('PORT', 5002))

# 환경 설정
is_prod = os.getenv('NODE_ENV') == 'production'

if is_prod:
    # 운영 환경: HTTPS
    server = pywsgi.WSGIServer(
        ('0.0.0.0', PORT),
        app,
        keyfile=r'C:\Users\Administrator\cert\privkey.pem',
        certfile=r'C:\Users\Administrator\cert\fullchain.pem'
    )
    print(f" Secure motion server running on https://0.0.0.0:{PORT}")
else:
    # 로컬 환경: HTTP
    server = pywsgi.WSGIServer(
        ('0.0.0.0', PORT),
        app
    )
    # run_server.py
print(f"Local motion server running on http://0.0.0.0:{PORT}")

server.serve_forever()
