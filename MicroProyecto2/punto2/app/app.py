# app.py
from flask import Flask, jsonify, request
import socket
import redis
import os
from datetime import datetime

app = Flask(__name__)

# Conectar a Redis (si está disponible)
try:
    redis_host = os.getenv('REDIS_HOST', 'localhost')
    r = redis.Redis(host=redis_host, port=6379, decode_responses=True)
    r.ping()
    redis_available = True
except:
    redis_available = False

@app.route('/')
def home():
    hostname = socket.gethostname()
    
    # Incrementar contador de visitas
    if redis_available:
        visits = r.incr('visit_count')
        r.lpush('visit_history', f"{hostname} - {datetime.now().strftime('%H:%M:%S')}")
        r.ltrim('visit_history', 0, 9)  # Mantener últimas 10 visitas
    else:
        visits = "Redis no disponible"
    
    return f'''
    <html>
        <head>
            <title>Mi App K8s Avanzada</title>
            <style>
                body {{
                    font-family: Arial;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    padding: 20px;
                }}
                .container {{
                    max-width: 800px;
                    margin: 0 auto;
                    background: rgba(0,0,0,0.3);
                    padding: 30px;
                    border-radius: 15px;
                }}
                h1 {{ color: #fff; text-align: center; }}
                .info-box {{
                    background: rgba(255,255,255,0.1);
                    padding: 15px;
                    border-radius: 10px;
                    margin: 15px 0;
                }}
                .counter {{
                    font-size: 48px;
                    text-align: center;
                    color: #ffd700;
                    margin: 20px 0;
                }}
                button {{
                    background: #3498db;
                    color: white;
                    border: none;
                    padding: 10px 20px;
                    border-radius: 5px;
                    cursor: pointer;
                    font-size: 16px;
                    margin: 5px;
                }}
                button:hover {{ background: #2980b9; }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Aplicación Multi-Pod en Kubernetes</h1>
                
                <div class="info-box">
                    <strong>Pod actual:</strong> {hostname}
                </div>
                
                <div class="counter">
                    Visitas totales: {visits}
                </div>
                
                <div style="text-align: center;">
                    <button onclick="location.reload()">Refrescar</button>
                    <button onclick="fetchInfo()">Info del Cluster</button>
                    <button onclick="resetCounter()">Reset Contador</button>
                </div>
                
                <div id="cluster-info" style="margin-top: 20px;"></div>
            </div>
            
            <script>
                function fetchInfo() {{
                    fetch('/api/info')
                        .then(r => r.json())
                        .then(data => {{
                            document.getElementById('cluster-info').innerHTML = 
                                '<div class="info-box"><h3>Información del Sistema</h3>' +
                                '<p>Hostname: ' + data.hostname + '</p>' +
                                '<p>Redis: ' + (data.redis_available ? 'Conectado' : 'No disponible') + '</p>' +
                                '<p>Hora: ' + data.timestamp + '</p></div>';
                        }});
                }}
                
                function resetCounter() {{
                    fetch('/api/reset', {{method: 'POST'}})
                        .then(r => r.json())
                        .then(data => {{
                            alert(data.message);
                            location.reload();
                        }});
                }}
            </script>
        </body>
    </html>
    '''

@app.route('/api/info')
def info():
    return jsonify({
        'hostname': socket.gethostname(),
        'redis_available': redis_available,
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'visits': r.get('visit_count') if redis_available else 0
    })

@app.route('/api/reset', methods=['POST'])
def reset():
    if redis_available:
        r.set('visit_count', 0)
        r.delete('visit_history')
        return jsonify({'message': 'Contador reseteado exitosamente'})
    return jsonify({'message': 'Redis no disponible'}), 503

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'redis': redis_available})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
