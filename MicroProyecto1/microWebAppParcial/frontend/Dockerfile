# Use an official Python runtime as a parent image
FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the frontend application code
COPY frontend/ .

# Expose the port the app runs on
EXPOSE 5001

# Define the command to run the app
ENV FLASK_APP=run.py
CMD ["flask", "run", "--host=0.0.0.0", "--port=5001"]
