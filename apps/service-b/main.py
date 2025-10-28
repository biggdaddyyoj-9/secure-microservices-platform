from fastapi import FastAPI
import logging
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()

# Logging setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("service-b")

Instrumentator().instrument(app).expose(app)

@app.get("/healthz")
def health_check():
    logger.info("Health check passed")
    return {"status": "ok"}

@app.get("/ping")
def ping():
    logger.info("Ping received from service-a")
    return {"message": "pong from service-b"}
