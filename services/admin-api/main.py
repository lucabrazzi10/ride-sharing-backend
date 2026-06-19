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
