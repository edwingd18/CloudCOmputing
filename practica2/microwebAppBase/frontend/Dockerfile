
FROM python:3.11-slim
WORKDIR /app




COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
ENV PYTHONUNBUFFERED=1 FLASK_APP=run.py


CMD ["flask", "run", "--host=0.0.0.0"]

