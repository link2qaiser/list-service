import pytest
from fastapi.testclient import TestClient
import os
import sys

# Add the parent directory to sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from main import app

# Create test client
client = TestClient(app)


def test_root_endpoint():
    """Test the root endpoint returns the correct response."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "endpoints" in data
    assert "/hello" in data["endpoints"]


def test_hello_endpoint():
    """Test the hello endpoint returns the correct response."""
    response = client.get("/hello")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "Hello World" in data["message"]
    assert "service" in data
    assert "powered_by" in data
    assert "FastAPI" in data["powered_by"]
