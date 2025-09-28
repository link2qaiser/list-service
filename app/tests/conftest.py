import pytest
import os


# Set test environment variables
@pytest.fixture(scope="session", autouse=True)
def set_test_environment():
    """Set environment variables for testing."""
    os.environ["ENVIRONMENT"] = "test"
    os.environ["LOG_LEVEL"] = "DEBUG"
    os.environ["API_TITLE"] = "Hello World API Test"
    os.environ["API_VERSION"] = "test"
