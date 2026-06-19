#!/bin/bash
# Scaffolds mock microservices for the Ride-Sharing Portfolio Project

echo "🚀 Bootstrapping Microservices..."

# ==========================================
# 1. ADMIN API (Python FastAPI)
# ==========================================
cat << 'EOF' > services/admin-api/main.py
import time
import random
from fastapi import FastAPI, Response, status

app = FastAPI(title="Admin-Backend-API")

@app.get("/healthz", status_code=status.HTTP_200_OK)
def liveness(): return {"status": "healthy"}

@app.get("/ready", status_code=status.HTTP_200_OK)
def readiness(): return {"status": "ready"}

@app.get("/api/v1/system-metrics")
def get_metrics():
    """Simulates fetching sensitive cluster metrics for the Admin dashboard."""
    time.sleep(random.uniform(0.01, 0.05)) # Fast internal latency
    return {
        "cpu_usage_pct": random.randint(20, 85),
        "memory_usage_pct": random.randint(40, 90),
        "active_database_connections": random.randint(50, 200),
        "active_users": random.randint(1000, 5000)
    }
EOF

cat << 'EOF' > services/admin-api/requirements.txt
fastapi==0.111.0
uvicorn==0.30.1
EOF

cat << 'EOF' > services/admin-api/Dockerfile
FROM python:3.11-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ./main.py ./main.py
RUN useradd -u 10001 sreuser && chown -R sreuser:sreuser /app
USER sreuser
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

# ==========================================
# 2. PAYMENT API (Python FastAPI)
# ==========================================
cat << 'EOF' > services/payment-api/main.py
import time
import random
from fastapi import FastAPI, Response, status

app = FastAPI(title="Payment-Backend-API")

@app.get("/healthz", status_code=status.HTTP_200_OK)
def liveness(): return {"status": "healthy"}

@app.get("/ready", status_code=status.HTTP_200_OK)
def readiness(): return {"status": "ready"}

@app.post("/api/v1/process-payment")
def process_payment(response: Response):
    """Simulates a third-party payment gateway interaction."""
    time.sleep(random.uniform(0.1, 0.6)) # Slower third-party latency
    
    # 5% failure rate to simulate 3rd party drops (Great for SLO monitoring)
    if random.random() < 0.05:
        response.status_code = status.HTTP_502_BAD_GATEWAY
        return {"error": "GatewayTimeout", "message": "Upstream payment provider failed to respond"}
        
    return {"status": "success", "transaction_id": f"txn_{random.randint(100000, 999999)}"}
EOF

cp services/admin-api/requirements.txt services/payment-api/requirements.txt
cp services/admin-api/Dockerfile services/payment-api/Dockerfile

# ==========================================
# 3. ADMIN UI (Nginx + Static HTML)
# ==========================================
cat << 'EOF' > services/admin-ui/index.html
<!DOCTYPE html>
<html>
<head><title>Internal Admin Portal</title></head>
<body style="font-family: Arial, sans-serif; padding: 40px; background-color: #f4f4f9;">
    <h2>🔒 RideShare Admin Dashboard</h2>
    <p>This UI is strictly internal. It fetches data from the Admin API over the private Kubernetes network.</p>
    <div style="padding: 20px; background: white; border-radius: 8px; border: 1px solid #ddd;">
        <p><strong>Status:</strong> Active</p>
        <p><strong>Environment:</strong> Production</p>
    </div>
</body>
</html>
EOF

cat << 'EOF' > services/admin-ui/Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF

# ==========================================
# 4. PAYMENT UI (Nginx + Static HTML)
# ==========================================
cat << 'EOF' > services/payment-ui/index.html
<!DOCTYPE html>
<html>
<head><title>Checkout - RideShare</title></head>
<body style="font-family: Arial, sans-serif; padding: 40px; background-color: #fff;">
    <h2>💳 Complete Your Ride Payment</h2>
    <p>This public-facing UI communicates securely with the Payment API.</p>
    <button style="padding: 10px 20px; background: #000; color: #fff; border: none; border-radius: 4px;">Submit Payment</button>
</body>
</html>
EOF

cp services/admin-ui/Dockerfile services/payment-ui/Dockerfile

echo "✅ All 4 mock microservices have been successfully generated!"