FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir flask-cors

COPY . /app
EXPOSE 5001
CMD ["python", "run.py"]
