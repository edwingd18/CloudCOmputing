from flask import Flask, render_template
from users.controllers.user_controller import user_controller
from db.db import db
from flask_cors import CORS
from flask_consulate import Consul

app = Flask(__name__)
CORS(app)
app.config.from_object('config.Config')
db.init_app(app)

# Healthcheck endpoint for Consul
@app.route('/healthcheck')
def health_check():
    """
    Health check endpoint for Consul monitoring
    """
    try:
        # Simple health check - could include DB connectivity, etc.
        return {'status': 'healthy', 'service': 'microUsers'}, 200
    except Exception as e:
        return {'status': 'unhealthy', 'error': str(e)}, 500

# Consul service discovery
consul = Consul(app=app)
consul.register_service(
    name='microUsers',
    interval='10s',
    tags=['microservice', 'users', 'api'],
    port=5002,
    httpcheck='http://192.168.50.4:5002/healthcheck'
)

# Registrando el blueprint del controlador de usuarios
app.register_blueprint(user_controller)

if __name__ == '__main__':
    app.run()
