import requests
from fastapi import FastAPI

app = FastAPI()

@app.get("/healthz")
def health_check():
    return {"status": "ok"}

@app.get("/hello")
def say_hello(name: str = "John"):
    return {"message": f"Hello, {name}!"}

@app.get("/call-b")
def call_service_b():
    try:
        response = requests.get("http://service-b/ping", timeout=2)
        return {"service-b-response": response.json()}
    except requests.exceptions.RequestException as e:
        return {"error": str(e)}
