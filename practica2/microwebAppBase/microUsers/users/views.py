import os
import time
import socket
import requests
from sqlalchemy import text
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

app = Flask(__name__)
# CORS solo para /api/*.
CORS(app, resources={r"/api/*": {"origins": "*"}})

# Carga de configuración (usa tus envs para MySQL)
app.config.from_object('config.Config')
db = SQLAlchemy(app)

# --------- Modelo ----------
class User(db.Model):
    __tablename__ = 'users'
    id    = db.Column(db.Integer, primary_key=True)
    name  = db.Column(db.String(255))
    email = db.Column(db.String(255))

# --------- Healthcheck ----------
@app.get("/health")
def health():
    return "ok", 200

# --------- Endpoints API ----------
# GET /api/users  -> lista usuarios  ✅
@app.get("/api/users")
def list_users():
    rows = User.query.order_by(User.id).all()
    data = [{"id": u.id, "name": u.name, "email": u.email} for u in rows]
    return jsonify(data), 200

# POST /api/users -> crea usuario (simple)
@app.post("/api/users")
def create_user():
    data = request.get_json(force=True) or {}
    name = data.get("name")
    email = data.get("email")
    if not name or not email:
        return jsonify({"error": "name y email son obligatorios"}), 400
    u = User(name=name, email=email)
    db.session.add(u)
    db.session.commit()
    return jsonify({"id": u.id, "name": u.name, "email": u.email}), 201

# (Opcional) GET /api/users/<id>
@app.get("/api/users/<int:user_id>")
def get_user(user_id):
    u = User.query.get_or_404(user_id)
    return jsonify({"id": u.id, "name": u.name, "email": u.email}), 200

# --------- Init DB con reintentos ----------
def init_db_with_retry(tries=30, delay=2):
    for i in range(tries):
        try:
            with app.app_context():
                # simple ping a la DB
                db.session.execute(text("SELECT 1"))
                db.create_all()
            print("DB ready ✔")
            return
        except Exception as e:
            print(f"DB not ready ({i+1}/{tries}): {e}")
            time.sleep(delay)
    raise RuntimeError("DB nunca estuvo lista")

# --------- Registro en Consul ----------
def register_with_consul():
    if os.getenv("USE_CONSUL", "0") != "1":
        print("Consul desactivado (USE_CONSUL!=1)")
        return

    consul_host = os.getenv("CONSUL_HOST", "consul")
    service_name = os.getenv("SERVICE_NAME", "microusers")
    service_port = int(os.getenv("SERVICE_PORT", "5002"))
    service_address = os.getenv("SERVICE_ADDRESS", "microusers")
    service_id = f"{service_name}-{socket.gethostname()}"

    payload = {
        "Name": service_name,
        "ID": service_id,
        "Address": service_address,
        "Port": service_port,
        "Tags": ["flask", "users"],
        "Check": {
            "HTTP": f"http://{service_address}:{service_port}/health",
            "Interval": "10s",
            "Timeout": "1s",
            "DeregisterCriticalServiceAfter": "1m"
        }
    }

    url = f"http://{consul_host}:8500/v1/agent/service/register"
    try:
        r = requests.put(url, json=payload, timeout=5)
        r.raise_for_status()
        print(f"Registrado en Consul ✔  ({service_name}:{service_port})")
    except Exception as e:
        print(f"No se pudo registrar en Consul: {e}")

# --------- Arranque (orden importante) ----------
if os.getenv("INIT_DB", "1") == "1":
    init_db_with_retry()

# registrarse en Consul al final
register_with_consul()

