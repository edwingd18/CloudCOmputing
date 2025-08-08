from flask import Flask, render_template
from products.controllers.product_controller import product_controller
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
        return {'status': 'healthy', 'service': 'microProducts'}, 200
    except Exception as e:
        return {'status': 'unhealthy', 'error': str(e)}, 500

# Consul service discovery
consul = Consul(app=app)
consul.register_service(
    name='microProducts',
    interval='10s',
    tags=['microservice', 'products', 'api'],
    port=5003,
    httpcheck='http://192.168.50.4:5003/healthcheck'
)

# Registrando el blueprint del controlador de productos
app.register_blueprint(product_controller)

if __name__ == '__main__':
    app.run()
