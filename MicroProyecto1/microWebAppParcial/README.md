# Microservices Web Application

## Como crear y ejecutar el proyecto

### 1. Inicializar la máquina virtual
```bash
vagrant up
vagrant ssh servidorWeb
```

### 2. Ejecutar la aplicación con Docker Compose
Una vez dentro de la VM, ejecutar:
```bash
docker-compose up
```

Este comando creará y ejecutará todos los servicios:
- Base de datos MySQL
- Microservicio de usuarios (puerto 5002)
- Microservicio de productos (puerto 5003) 
- Microservicio de órdenes (puerto 5004)
- Frontend web (puerto 5001)
- Consul para service discovery (puerto 8500)

## Endpoints para comprobar

### Frontend
- **URL principal**: http://192.168.80.3:5001
- Interfaz web para gestionar usuarios, productos y órdenes

### API Endpoints

#### Usuarios (puerto 5002)
- `GET /users` - Listar todos los usuarios
- `POST /users` - Crear nuevo usuario
- `GET /users/<id>` - Obtener usuario por ID
- `PUT /users/<id>` - Actualizar usuario
- `DELETE /users/<id>` - Eliminar usuario

#### Productos (puerto 5003)
- `GET /products` - Listar todos los productos
- `POST /products` - Crear nuevo producto
- `GET /products/<id>` - Obtener producto por ID
- `PUT /products/<id>` - Actualizar producto
- `DELETE /products/<id>` - Eliminar producto

#### Órdenes (puerto 5004)
- `GET /orders` - Listar todas las órdenes
- `POST /orders` - Crear nueva orden
- `GET /orders/<id>` - Obtener orden por ID
- `PUT /orders/<id>` - Actualizar orden
- `DELETE /orders/<id>` - Eliminar orden

### Consul
- **UI de Consul**: http://192.168.80.3:8500
- Panel de administración para service discovery
