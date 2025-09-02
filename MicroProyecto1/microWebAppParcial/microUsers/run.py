from users.views import app
from consul_client import register_with_consul
import threading

def register_service_async():
    """Register service with Consul in a separate thread"""
    print("🚀 Starting Consul registration for users service...")
    try:
        success = register_with_consul('users', 5002)
        if success:
            print("✓ Users service registration completed")
        else:
            print("✗ Users service registration failed")
    except Exception as e:
        print(f"✗ Error during Consul registration: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    print("🏁 Starting users microservice...")
    # Start registration in background thread
    registration_thread = threading.Thread(target=register_service_async, daemon=True)
    registration_thread.start()
    
    # Start the Flask app
    print("🌐 Starting Flask app on 0.0.0.0:5002...")
    app.run(host='0.0.0.0', port=5002)
