from fastapi import FastAPI

app = FastAPI()

@app.get("/healthz")
def health_check():
    return {"status": "ok"}

@app.get("/ping")
def ping():
    return {"message": "pong from service-b"}
