from fastapi import FastAPI, Request, HTTPException
from mangum import Mangum
from pydantic import BaseModel
from typing import List, Optional
import os
from dotenv import load_dotenv
import logging
import time
import json
import boto3
from botocore.exceptions import ClientError

# Load environment variables from .env file if it exists
# This will be used for local development
if os.path.exists(".env"):
    load_dotenv()

# In-memory storage for the list of strings
string_list = [
    "apple",
    "banana",
    "cherry",
    "date",
    "elderberry",
]  # Sample data for testing


# Pydantic models for response validation
class HeadTailResponse(BaseModel):
    items: List[str]
    count: int


# Load configuration from AWS Secrets Manager in Lambda environment
def get_secret():
    # Only try to access Secrets Manager if not in local development
    if os.environ.get("AWS_LAMBDA_FUNCTION_NAME"):
        secret_name = f"{os.environ.get('ENVIRONMENT')}-list-service-api-config"
        region_name = os.environ.get("AWS_REGION", "us-east-2")

        try:
            session = boto3.session.Session()
            client = session.client(
                service_name="secretsmanager", region_name=region_name
            )

            response = client.get_secret_value(SecretId=secret_name)
            if "SecretString" in response:
                secret = json.loads(response["SecretString"])
                # Update environment with secrets
                for key, value in secret.items():
                    os.environ[key] = value
                return True
        except ClientError as e:
            logging.error(f"Error accessing Secret Manager: {str(e)}")
            return False
    return False


# Try to load secrets, but continue even if it fails
# This makes the app work in both local dev and AWS environments
try:
    get_secret()
except Exception as e:
    logging.warning(f"Could not load secrets: {str(e)}")

# Configure logging
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()
logging.basicConfig(
    level=getattr(logging, LOG_LEVEL),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger("list-service")

# Environment configuration
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")
API_TITLE = os.getenv("API_TITLE", "ListService")
API_DESCRIPTION = os.getenv(
    "API_DESCRIPTION",
    "HTTP REST API for list operations with head and tail functionality",
)
API_VERSION = os.getenv("API_VERSION", "0.1.0")
DEBUG = os.getenv("DEBUG", "False").lower() in ("true", "1", "t")

app = FastAPI(
    title=API_TITLE, description=API_DESCRIPTION, version=API_VERSION, debug=DEBUG
)


# Middleware for request logging
@app.middleware("http")
async def log_requests(request: Request, call_next):
    logger.info(f"Request started: {request.method} {request.url.path}")
    start_time = time.time()

    try:
        response = await call_next(request)
        process_time = time.time() - start_time
        logger.info(
            f"Request completed: {request.method} {request.url.path} - "
            f"Status: {response.status_code} - Duration: {process_time:.4f}s"
        )
        return response
    except Exception as e:
        process_time = time.time() - start_time
        logger.error(
            f"Request failed: {request.method} {request.url.path} - "
            f"Error: {str(e)} - Duration: {process_time:.4f}s"
        )
        raise


@app.get("/")
async def root():
    """
    Root endpoint - ListService HTTP REST API
    """
    logger.info("Root endpoint called")
    return {
        "service": "ListService",
        "description": "HTTP REST API for list operations",
        "operations": {
            "head": "/list/head - Get first element(s) from the list",
            "tail": "/list/tail - Get last element(s) from the list",
        },
        "current_list": string_list,
    }


@app.get("/list/head", response_model=HeadTailResponse)
async def head(count: Optional[int] = 1):
    """
    HEAD operation - Get the first element(s) from the list of strings
    """
    logger.info(f"Head operation called with count={count}")

    if count < 1:
        raise HTTPException(status_code=400, detail="Count must be at least 1")

    # Head operation: get first 'count' elements
    head_items = string_list[:count]

    response_data = HeadTailResponse(items=head_items, count=len(head_items))
    logger.debug(f"Head operation result: {response_data.dict()}")
    return response_data


@app.get("/list/tail", response_model=HeadTailResponse)
async def tail(count: Optional[int] = 1):
    """
    TAIL operation - Get the last element(s) from the list of strings
    """
    logger.info(f"Tail operation called with count={count}")

    if count < 1:
        raise HTTPException(status_code=400, detail="Count must be at least 1")

    # Tail operation: get last 'count' elements
    tail_items = string_list[-count:] if count <= len(string_list) else string_list

    response_data = HeadTailResponse(items=tail_items, count=len(tail_items))
    logger.debug(f"Tail operation result: {response_data.dict()}")
    return response_data


# Lambda handler
handler = Mangum(app)

# Add this section for local development
if __name__ == "__main__":
    import uvicorn

    logger.info(f"Starting ListService in {ENVIRONMENT} environment")
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
