# Usar Python como imagen base
FROM python:3.9-slim

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos
COPY requirements.txt .
COPY app.py .

# Instalar dependencias
RUN pip install -r requirements.txt

# Exponer el puerto
EXPOSE 5000

# Comando para iniciar
CMD ["python", "app.py"]
