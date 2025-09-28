import pytest
import requests
import os

"""
These tests are designed to run against a live API endpoint.
Pass the API URL as an environment variable:
API_URL=https://your-api-endpoint pytest tests/regression/test_live_api.py
"""

# Get API URL from environment variable
API_URL = os.environ.get("API_URL")

# Skip all tests if API_URL is not set
pytestmark = pytest.mark.skipif(
    API_URL is None, reason="API_URL environment variable not set"
)


def test_live_root_endpoint():
    """Test the root endpoint of the live API."""
    response = requests.get(f"{API_URL}/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "endpoints" in data


def test_live_hello_endpoint():
    """Test the hello endpoint of the live API."""
    response = requests.get(f"{API_URL}/hello")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "Hello World" in data["message"]
    assert "service" in data
    assert "powered_by" in data


def test_live_performance():
    """Test API response time is within acceptable limits."""
    response = requests.get(f"{API_URL}/hello")
    assert response.elapsed.total_seconds() < 1.0, "API response took too long"
