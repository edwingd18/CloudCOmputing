from flask import Blueprint, request, jsonify
from products.models.product_model import Products
from db.db import db

product_controller = Blueprint('product_controller', __name__)

@product_controller.route('/api/products', methods=['GET'])
def get_products():
    print("listado de productos")
    products = Products.query.all()
    result = [{'id':product.id, 'name': product.name, 'price':product.price, 'stock':product.stock, 'description':product.description } for product in products]
    return jsonify(result)

# Get single user by id
@product_controller.route('/api/products/<int:product_id>', methods=['GET'])
def get_product(product_id):
    print("obteniendo producto")
    product = Products.query.get_or_404(product_id)
    return jsonify({'id': product.id, 'name': product.name, 'price': product.price, 'stock': product.stock, 'description': product.description})

@product_controller.route('/api/products', methods=['POST'])
def create_product():
    print("creando producto")
    data = request.json
    #new_user = Users(name="oscar", email="oscar@gmail", username="omondragon", password="123")
    new_product = Products(name=data['name'], price=data['price'], stock=data['stock'], description=data['description'])
    db.session.add(new_product)
    db.session.commit()
    return jsonify({'message': 'Producto creado exitosamente'}), 201

# Update an existing user
@product_controller.route('/api/products/<int:product_id>', methods=['PUT'])
def update_product(product_id):
    print("actualizando producto")
    product = Products.query.get_or_404(product_id)
    data = request.json
    product.name = data['name']
    product.price = data['price']
    product.stock = data['stock']
    product.description = data['description']
    db.session.commit()
    return jsonify({'message': 'UProducto creado exitosamente'})

# Delete an existing user
@product_controller.route('/api/products/<int:product_id>', methods=['DELETE'])
def delete_user(product_id):
    product = Products.query.get_or_404(product_id)
    db.session.delete(product)
    db.session.commit()
    return jsonify({'message': 'User deleted successfully'})
