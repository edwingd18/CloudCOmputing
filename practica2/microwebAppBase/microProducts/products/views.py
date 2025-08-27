import os
from decimal import Decimal, InvalidOperation

from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

app = Flask(__name__)

# CORS para todo lo bajo /api/*
CORS(app, resources={r"/api/*": {"origins": "*"}})

# Carga configuración (e.g. URI MySQL, etc.)
app.config.from_object("config.Config")

db = SQLAlchemy(app)


# -----------------------------
# Modelo
# -----------------------------
class Product(db.Model):
    __tablename__ = "products"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=True)        # puedes poner nullable=False si ya saneaste datos
    # Usa DECIMAL(10,2) para que coincida con tu tabla MySQL
    price = db.Column(db.Numeric(10, 2), nullable=True)    # idem: cámbialo a False si quieres forzar
    stock = db.Column(db.Integer, default=0)
    description = db.Column(db.String(255), default="")

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            # Convertir Decimal -> float/string para JSON
            "price": float(self.price) if self.price is not None else None,
            "stock": self.stock,
            "description": self.description,
        }


# -----------------------------
# Health
# -----------------------------
@app.get("/health")
def health():
    return "ok", 200


# -----------------------------
# Endpoints API
# -----------------------------
@app.get("/api/products")
def list_products():
    rows = Product.query.all()
    return jsonify([p.to_dict() for p in rows]), 200


@app.get("/api/products/<int:pid>")
def get_product(pid: int):
    p = Product.query.get_or_404(pid)
    return jsonify(p.to_dict()), 200


@app.post("/api/products")
def create_product():
    data = request.get_json(silent=True) or {}

    name = (data.get("name") or "").strip()
    price_raw = data.get("price")
    stock_raw = data.get("stock")
    description = (data.get("description") or "").strip()

    # Validaciones básicas
    if not name:
        return jsonify({"error": "name es obligatorio"}), 400

    try:
        # Acepta números o strings; normaliza a Decimal con 2 decimales
        price = Decimal(str(price_raw))
    except (InvalidOperation, TypeError):
        return jsonify({"error": "price debe ser numérico"}), 400

    try:
        stock = int(stock_raw) if stock_raw is not None else 0
    except (ValueError, TypeError):
        return jsonify({"error": "stock debe ser entero"}), 400

    p = Product(name=name, price=price, stock=stock, description=description)
    db.session.add(p)
    db.session.commit()

    return jsonify(p.to_dict()), 201


@app.put("/api/products/<int:pid>")
@app.patch("/api/products/<int:pid>")
def update_product(pid: int):
    p = Product.query.get_or_404(pid)
    data = request.get_json(silent=True) or {}

    if "name" in data:
        p.name = (data.get("name") or "").strip()

    if "price" in data:
        try:
            p.price = Decimal(str(data.get("price")))
        except (InvalidOperation, TypeError):
            return jsonify({"error": "price debe ser numérico"}), 400

    if "stock" in data:
        try:
            p.stock = int(data.get("stock"))
        except (ValueError, TypeError):
            return jsonify({"error": "stock debe ser entero"}), 400

    if "description" in data:
        p.description = (data.get("description") or "").strip()

    db.session.commit()
    return jsonify(p.to_dict()), 200


@app.delete("/api/products/<int:pid>")
def delete_product(pid: int):
    p = Product.query.get_or_404(pid)
    db.session.delete(p)
    db.session.commit()
    return "", 204


# -----------------------------
# Inicializa tablas si no existen
# -----------------------------
with app.app_context():
    db.create_all()

