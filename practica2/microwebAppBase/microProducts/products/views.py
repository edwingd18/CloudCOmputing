import os
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": "*"}})
app.config.from_object('config.Config')
db = SQLAlchemy(app)

class Product(db.Model):
    __tablename__ = 'products'
    id    = db.Column(db.Integer, primary_key=True)
    name  = db.Column(db.String(255))
    price = db.Column(db.Float)

@app.get("/health")
def health():
    return "ok", 200


@app.get("/api/products")
def list_products():
    rows = Product.query.all()
    return jsonify([{"id":p.id, "name":p.name, "price":p.price} for p in rows]), 200

@app.post("/api/products")
def create_product():
    data = request.get_json(force=True)
    p = Product(name=data.get("name"), price=data.get("price"))
    db.session.add(p)
    db.session.commit()
    return jsonify({"id": p.id}), 201

with app.app_context():
    db.create_all()
