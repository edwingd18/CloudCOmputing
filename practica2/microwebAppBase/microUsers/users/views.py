import os
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config.from_object('config.Config')
db = SQLAlchemy(app)

# Modelo (ajusta campos a tu init.sql si hace falta)
class User(db.Model):
    __tablename__ = 'users'
    id    = db.Column(db.Integer, primary_key=True)
    name  = db.Column(db.String(255))
    email = db.Column(db.String(255))

@app.get("/health")
def health():
    return "ok", 200

# NUEVO: lista usuarios
@app.get("/api/users")
def list_users():
    rows = User.query.all()
    return jsonify([{"id":u.id, "name":u.name, "email":u.email} for u in rows]), 200

# NUEVO: crea usuario
@app.post("/api/users")
def create_user():
    data = request.get_json(force=True)
    u = User(name=data.get("name"), email=data.get("email"))
    db.session.add(u)
    db.session.commit()
    return jsonify({"id": u.id}), 201

# Opcional en dev: crea tablas si no existen
with app.app_context():
    db.create_all()
