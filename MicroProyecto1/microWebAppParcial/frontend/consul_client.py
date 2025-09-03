import os
import socket
import time
import atexit
import requests

class ConsulClient:
    def __init__(self, service_name, service_port, consul_host='consul', consul_port=8500):
        self.service_name = service_name
        self.service_port = service_port
        self.consul_host = consul_host
        self.consul_port = consul_port
        self.service_id = f"{service_name}-{self.get_service_ip()}-{service_port}"
        self.registered = False
        
    def get_service_ip(self):
        """Get the actual IP address to register with Consul"""
        # Try environment variable first
        env_ip = os.getenv('SERVICE_ADDRESS')
        if env_ip and env_ip != self.service_name:
            return env_ip
        
        # Get container IP
        try:
            hostname = socket.gethostname()
            ip = socket.gethostbyname(hostname)
            if ip and ip != '127.0.0.1':
                return ip
        except:
            pass
            
        # Fallback
        return '192.168.80.3'
    
    def wait_for_consul(self, max_retries=30, wait_seconds=2):
        """Wait for Consul to be available"""
        for attempt in range(max_retries):
            try:
                response = requests.get(f"http://{self.consul_host}:{self.consul_port}/v1/status/leader", timeout=5)
                if response.status_code == 200:
                    print(f"✓ Consul is available at {self.consul_host}:{self.consul_port}")
                    return True
            except requests.exceptions.RequestException as e:
                print(f"Waiting for Consul... attempt {attempt + 1}/{max_retries} ({e})")
                time.sleep(wait_seconds)
        
        print(f"✗ Consul not available after {max_retries} attempts")
        return False
    
    def register_service(self, max_retries=5):
        """Register service with Consul with retry logic"""
        if not self.wait_for_consul():
            print("Cannot register service - Consul not available")
            return False
            
        service_ip = self.get_service_ip()
        
        service_data = {
            "Name": self.service_name,
            "ID": self.service_id,
            "Address": service_ip,
            "Port": self.service_port,
            "Tags": ["frontend", self.service_name],
            "Check": {
                "HTTP": f"http://{service_ip}:{self.service_port}/health",
                "Interval": "10s",
                "Timeout": "3s"
            }
        }
        
        for attempt in range(max_retries):
            try:
                response = requests.put(
                    f"http://{self.consul_host}:{self.consul_port}/v1/agent/service/register",
                    json=service_data,
                    timeout=10
                )
                
                if response.status_code == 200:
                    print(f"✓ Service {self.service_name} registered successfully with Consul")
                    print(f"  - Service ID: {self.service_id}")
                    print(f"  - Address: {service_ip}:{self.service_port}")
                    print(f"  - Health Check: http://{service_ip}:{self.service_port}/health")
                    self.registered = True
                    atexit.register(self.deregister_service)
                    return True
                else:
                    print(f"Failed to register service, status code: {response.status_code}")
                    print(f"Response: {response.text}")
                    
            except requests.exceptions.RequestException as e:
                print(f"Error registering service (attempt {attempt + 1}/{max_retries}): {e}")
                if attempt < max_retries - 1:
                    time.sleep(2)
        
        print(f"✗ Failed to register service {self.service_name} after {max_retries} attempts")
        return False
    
    def deregister_service(self):
        """Deregister service from Consul"""
        if not self.registered:
            return
            
        try:
            response = requests.put(
                f"http://{self.consul_host}:{self.consul_port}/v1/agent/service/deregister/{self.service_id}",
                timeout=5
            )
            if response.status_code == 200:
                print(f"✓ Service {self.service_name} deregistered from Consul")
            else:
                print(f"Warning: Failed to deregister service, status code: {response.status_code}")
        except Exception as e:
            print(f"Warning: Error deregistering service: {e}")

def register_with_consul(service_name, service_port):
    """Helper function to register a service with Consul"""
    consul_client = ConsulClient(service_name, service_port)
    return consul_client.register_service()