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
