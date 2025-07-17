from main import app
from gevent import pywsgi

PORT = 5001

server = pywsgi.WSGIServer(
    ('0.0.0.0', PORT),
    app,
    keyfile=r'C:\Users\Administrator\cert\privkey.pem',
    certfile=r'C:\Users\Administrator\cert\fullchain.pem'
)

print(f"✅ Secure motion server running on https://0.0.0.0:{PORT}")
server.serve_forever()
