import requests
import logging
from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("service-a")

Instrumentator().instrument(app).expose(app)

@app.get("/healthz")
def health_check():
    logger.info("Health check passed")
    return {"status": "ok"}

@app.get("/hello")
def say_hello(name: str = "John"):
    logger.info(f"Greeting {name}")
    return {"message": f"Hello, {name}!"}

@app.get("/call-b")
def call_service_b():
    try:
        response = requests.get("http://localhost:8001/ping", timeout=2)
        logger.info("Called service-b successfully")
        return {"service-b-response": response.json()}
    except requests.exceptions.RequestException as e:
        logger.error(f"Error calling service-b: {e}")
        return {"error": str(e)}
