from web.views import app
from consul_client import register_with_consul
import threading
from flask import jsonify

def register_service_async():
    """Register service with Consul in a separate thread"""
    print("🚀 Starting Consul registration for frontend service...")
    try:
        success = register_with_consul('frontend', 5001)
        if success:
            print("✓ Frontend service registration completed")
        else:
            print("✗ Frontend service registration failed")
    except Exception as e:
        print(f"✗ Error during Consul registration: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    print("🏁 Starting frontend microservice...")
    # Start registration in background thread
    registration_thread = threading.Thread(target=register_service_async, daemon=True)
    registration_thread.start()
    
    # Start the Flask app
    print("🌐 Starting Flask app on 0.0.0.0:5001...")
    app.run(host='0.0.0.0', port=5001)
