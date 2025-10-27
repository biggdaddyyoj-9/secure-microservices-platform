from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_healthz():
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_hello():
    response = client.get("/hello?name=John")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello, John!"}
