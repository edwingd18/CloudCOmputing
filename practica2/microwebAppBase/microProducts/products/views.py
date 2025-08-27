import os
import time
import socket
import requests
from sqlalchemy import text
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": "*"}})

# Config por objeto (usa tus ENV en config.Config)
app.config.from_object('config.Config')
db = SQLAlchemy(app)

# --------- Modelo (ajústalo a tu init.sql si hace falta) ----------
class Product(db.Model):
    __tablename__ = 'products'
    id          = db.Column(db.Integer, primary_key=True)
    name        = db.Column(db.String(255), nullable=False)
    price       = db.Column(db.Float, nullable=False, default=0.0)
    stock       = db.Column(db.Integer, nullable=False, default=0)
    description = db.Column(db.Text)

# --------- Healthcheck ----------
@app.get("/health")
def health():
    return "ok", 200

# --------- Endpoints API ----------
# GET /api/products -> lista de productos
@app.get("/api/products")
def list_products():
    rows = Product.query.order_by(Product.id).all()
    data = [{
        "id": p.id,
        "name": p.name,
        "price": p.price,
        "stock": p.stock,
        "description": p.description
    } for p in rows]
    return jsonify(data), 200

# POST /api/products -> crea producto
@app.post("/api/products")
def create_product():
    data = request.get_json(force=True) or {}
    name  = data.get("name")
    price = data.get("price", 0.0)
    stock = data.get("stock", 0)
    desc  = data.get("description")

    if not name:
        return jsonify({"error": "name es obligatorio"}), 400

    try:
        price = float(price)
        stock = int(stock)
    except Exception:
        return jsonify({"error": "price debe ser número y stock entero"}), 400

    p = Product(name=name, price=price, stock=stock, description=desc)
    db.session.add(p)
    db.session.commit()
    return jsonify({
        "id": p.id, "name": p.name, "price": p.price,
        "stock": p.stock, "description": p.description
    }), 201

# (Opcional) GET /api/products/<id>
@app.get("/api/products/<int:product_id>")
def get_product(product_id):
    p = Product.query.get_or_404(product_id)
    return jsonify({
        "id": p.id, "name": p.name, "price": p.price,
        "stock": p.stock, "description": p.description
    }), 200

# --------- Init DB con reintentos ----------
def init_db_with_retry(tries=30, delay=2):
    for i in range(tries):
        try:
            with app.app_context():
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
    service_name = os.getenv("SERVICE_NAME", "microproducts")
    service_port = int(os.getenv("SERVICE_PORT", "5003"))
    service_address = os.getenv("SERVICE_ADDRESS", "microproducts")
    service_id = f"{service_name}-{socket.gethostname()}"

    payload = {
        "Name": service_name,
        "ID": service_id,
        "Address": service_address,
        "Port": service_port,
        "Tags": ["flask", "products"],
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

# --------- Arranque ---------.-
if os.getenv("INIT_DB", "1") == "1":
    init_db_with_retry()

register_with_consul()

