from flask import Blueprint, request, jsonify
import requests
from orders.models.order_model import Order, OrderItem
from db.db import db

order_controller = Blueprint('order_controller', __name__)

PRODUCTS_API_URL = "http://192.168.80.3:5003/api/products"

@order_controller.route('/api/orders', methods=['GET'])
def get_all_orders():
    try:
        orders = Order.query.all()
        result = []
        for order in orders:
            order_data = {
                'id': order.id,
                'user_name': order.user_name,
                'user_email': order.user_email,
                'sale_total': order.sale_total,
                'date': order.date.isoformat(),
                'items': []
            }
            for item in order.items:
                order_data['items'].append({
                    'product_id': item.product_id,
                    'quantity': item.quantity,
                    'price': item.price
                })
            result.append(order_data)
        return jsonify(result), 200
    except Exception as e:
        return jsonify({'message': 'Error fetching orders', 'error': str(e)}), 500

@order_controller.route('/api/orders/<int:order_id>', methods=['GET'])
def get_order(order_id):
    try:
        order = Order.query.get_or_404(order_id)
        order_data = {
            'id': order.id,
            'user_name': order.user_name,
            'user_email': order.user_email,
            'sale_total': order.sale_total,
            'date': order.date.isoformat(),
            'items': []
        }
        for item in order.items:
            order_data['items'].append({
                'product_id': item.product_id,
                'quantity': item.quantity,
                'price': item.price
            })
        return jsonify(order_data), 200
    except Exception as e:
        return jsonify({'message': 'Error fetching order', 'error': str(e)}), 500

@order_controller.route('/api/orders', methods=['POST'])
def create_order():
    data = request.get_json()
    user_info = data.get('user')
    if not user_info or not user_info.get('name') or not user_info.get('email'):
        return jsonify({'message': 'Información de usuario inválida'}), 400

    user_name = user_info['name']
    user_email = user_info['email']
    
    products_to_order = data.get('products')
    if not products_to_order or not isinstance(products_to_order, list):
        return jsonify({'message': 'Falta o es inválida la información de los productos'}), 400

    sale_total = 0
    product_details = []
    
    # 1. Verify product availability and calculate total
    for item in products_to_order:
        product_id = item.get('id')
        quantity = item.get('quantity')

        try:
            response = requests.get(f"{PRODUCTS_API_URL}/{product_id}")
            if response.status_code != 200:
                return jsonify({'message': f"Producto con ID {product_id} no encontrado."}), 404
            
            product = response.json()
            
            if product['stock'] < quantity:
                return jsonify({'message': f"Stock insuficiente para el producto {product['name']}. Disponible: {product['stock']}, Solicitado: {quantity}"}), 400
            
            sale_total += product['price'] * quantity
            product_details.append({
                'id': product_id,
                'name': product['name'],
                'new_stock': product['stock'] - quantity,
                'price': product['price'],
                'quantity_ordered': quantity,
                'description': product['description']
            })

        except requests.exceptions.RequestException as e:
            return jsonify({'message': 'Error al comunicarse con el servicio de productos', 'error': str(e)}), 500

    # 2. Create order and update inventory
    try:
        # Create Order
        new_order = Order(user_name=user_name, user_email=user_email, sale_total=sale_total)
        db.session.add(new_order)
        db.session.flush() # Use flush to get the new_order.id before committing

        # Create OrderItems and Update Stock
        for product in product_details:
            # Create order item
            order_item = OrderItem(order_id=new_order.id, product_id=product['id'], quantity=product['quantity_ordered'], price=product['price'])
            db.session.add(order_item)

            # Update product stock via API
            update_payload = {
                'name': product['name'],
                'price': product['price'],
                'stock': product['new_stock'],
                'description': product['description']
            }
            update_response = requests.put(f"{PRODUCTS_API_URL}/{product['id']}", json=update_payload)
            if update_response.status_code != 200:
                # If stock update fails, rollback transaction
                db.session.rollback()
                return jsonify({'message': f"Error al actualizar el stock para el producto ID {product['id']}"}), 500

        db.session.commit()
        return jsonify({'message': 'Orden creada exitosamente'}), 201

    except Exception as e:
        db.session.rollback()
        import traceback
        traceback.print_exc()
        return jsonify({'message': 'Error al crear la orden en la base de datos', 'error': str(e)}), 500
