FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Copy and install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy Flask app
COPY app.py .

# Ensure logs are unbuffered for Kubernetes
ENV PYTHONUNBUFFERED=1

# Run app using gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]



