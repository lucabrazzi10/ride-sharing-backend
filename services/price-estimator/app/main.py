import os
import time
import random
from fastapi import FastAPI, Response, status, Query
import psycopg2

app = FastAPI(title="RideShare-PriceEstimator-Service")

# Database configuration from environment variables
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "postgres")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "password")

def get_db_connection():
    return psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )

@app.get("/healthz", status_code=status.HTTP_200_OK)
def liveness():
    """Liveness probe: Tells Kubernetes if the app process is alive."""
    return {"status": "healthy"}

@app.get("/ready", status_code=status.HTTP_200_OK)
def readiness(response: Response):
    """Readiness probe: Tells Kubernetes if the app can safely accept user traffic."""
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT 1;")
        cur.close()
        conn.close()
        return {"status": "ready", "database": "connected"}
    except Exception as e:
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
        return {"status": "unready", "db_error": str(e)}

@app.get("/api/v1/estimate-price")
def estimate_price(
    response: Response, 
    distance_miles: float = Query(..., gte=0.1), 
    surge_multiplier: float = Query(1.0, gte=1.0)
):
    """
    Calculates ride cost. Simulates database lookups for active drivers.
    Includes intentional random failures and variable latency for SRE metrics tracking.
    """
    start_time = time.time()
    
    # 1. Simulate an intermittent 5% failure rate (SRE practice for Error Budgets/SLOs)
    if random.random() < 0.05:
        response.status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
        return {"error": "InternalServerException", "message": "Failed to calculate dynamic pricing surge"}
        
    # 2. Simulate database round-trip latency (simulating a complex query path)
    # Latency varies naturally between 40ms and 350ms
    simulated_latency = random.uniform(0.04, 0.35)
    time.sleep(simulated_latency)
    
    # 3. Simple production pricing logic
    base_fare = 2.50
    per_mile_rate = 1.75
    calculated_fare = (base_fare + (distance_miles * per_mile_rate)) * surge_multiplier
    
    duration = time.time() - start_time
    
    return {
        "service": "price-estimator",
        "distance_miles": distance_miles,
        "surge_multiplier": surge_multiplier,
        "estimated_fare_usd": round(calculated_fare, 2),
        "server_processing_time_sec": round(duration, 4)
    }
