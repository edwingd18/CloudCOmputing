from flask import Flask, render_template, jsonify
from users.controllers.user_controller import user_controller
from db.db import db
from flask_cors import CORS

app = Flask(__name__)
app.secret_key = 'secret123'
app.config.from_object('config.Config')
db.init_app(app)

# Health check endpoint para Consul
@app.route('/health')
def health_check():
    return jsonify({"status": "healthy", "service": "users"}), 200

# Registrando el blueprint del controlador de usuarios
app.register_blueprint(user_controller)
CORS(app, resources={r"/api/*": {"origins": "*"}}, supports_credentials=True)

if __name__ == '__main__':
    app.run()
