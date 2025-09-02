from flask import Flask, jsonify
from products.controllers.product_controller import product_controller
from db.db import db
from flask_cors import CORS

app = Flask(__name__)
app.secret_key = 'secret123'
app.config.from_object('config.Config')
db.init_app(app)

# Health check endpoint para Consul
@app.route('/health')
def health_check():
    return jsonify({"status": "healthy", "service": "products"}), 200

# Registrando el blueprint del controlador de productos
app.register_blueprint(product_controller)
CORS(app, resources={r"/api/*": {"origins": "*"}}, supports_credentials=True)

if __name__ == '__main__':
    app.run()
