from db.db import db

class Products(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    price = db.Column(db.Numeric(10, 2), nullable=False)
    stock = db.Column(db.Integer, nullable=False)
    description = db.Column(db.String(255), nullable=True)
    

    def __init__(self, name, price, stock, description=None):
        self.name = name
        self.price = price
        self.stock = stock
        self.description = description
