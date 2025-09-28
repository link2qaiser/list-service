# AWS Lambda ListService API

A serverless ListService API built on AWS Lambda with API Gateway integration. This project uses FastAPI for the API implementation with a split workflow for infrastructure and code management.

## Project Overview

This repository contains:

- A FastAPI application deployed as an AWS Lambda function
- Terraform configurations for infrastructure management
- Serverless Framework for code deployments
- GitHub Actions workflow for CI/CD of code changes

## Deployment Strategy

This project uses a hybrid approach:

1. **Infrastructure**: Managed manually using Terraform from local development machine
2. **Code**: Deployed automatically via GitHub Actions using Serverless Framework

This separation allows for:
- Controlled infrastructure changes
- Fast and frequent code deployments
- Clear separation of concerns

## Architecture

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│             │      │             │      │             │
│  API        │──────▶  Lambda     │      │ CloudWatch  │
│  Gateway    │      │  Function   │──────▶ Logs        │
│             │      │  (FastAPI)  │      │             │
└─────────────┘      └─────────────┘      └─────────────┘
```

## Features

- **FastAPI Implementation**: Modern, fast API framework with automatic OpenAPI documentation
- **Multi-environment Support**: Separate configurations for dev, stage, and production
- **Infrastructure as Code**: AWS resources defined and managed with Terraform
- **CI/CD for Code**: Automated testing and deployment of code changes
- **Lambda Layers**: Dependencies managed through Lambda layers
- **Makefile**: Convenient commands for development and deployment
- **List Operations**: Support for head and tail operations on lists of strings

## Key Components

### Application Code (app/)
- FastAPI application code
- Automatically deployed by GitHub Actions

### Infrastructure (environments/ and modules/)
- Terraform configurations
- Managed manually from local machine

### Deployment (serverless.yml)
- Serverless Framework configuration
- Deploys code to existing infrastructure

## Getting Started

### Prerequisites

- AWS Account
- AWS CLI configured locally
- Terraform CLI (for infrastructure management)
- Node.js and npm (for Serverless Framework)
- Python 3.9+ (for local API development)

### AWS Profile Setup

First, configure your AWS credentials and profile:

```bash
# Configure AWS CLI with your credentials
aws configure

# Or if you want to use a specific profile
aws configure --profile your-profile-name

# Set the profile as default (optional)
export AWS_PROFILE=your-profile-name

# Verify your configuration
aws sts get-caller-identity
```

### Quick Commands (using Makefile)

**Note:** You can create a local virtual environment before running commands.

Example:
```bash
cd app
python -m venv env
source env/bin/activate  # On Windows: env\Scripts\activate
cd ..
```

```bash
# Local development
make install     # Install Python dependencies
make local-run   # Run API locally at http://localhost:8000
make test        # Run tests

# Infrastructure management
make init        # Initialize Terraform
make plan        # Review infrastructure changes
make apply       # Deploy infrastructure changes
make destroy     # Destroy infrastructure
```

### Infrastructure Deployment

See [TERRAFORM_INFRASTRUCTURE.md](TERRAFORM_INFRASTRUCTURE.md) for detailed instructions.

```bash
# Initial setup
make init
make apply
```

### Updating Infrastructure

When you need to make changes to the infrastructure:

```bash
make plan    # Review changes
make apply   # Apply changes
```

### Local API Development

You can develop and test the FastAPI application locally:

```bash
make install    # Install dependencies
make local-run   # Start local server
```

The API will be available at http://localhost:8000 with documentation at http://localhost:8000/docs

## API Endpoints

The ListService provides the following endpoints:

- `GET /` - Root endpoint with API information
- `GET /list/head` - Get the first element(s) from the list
- `GET /list/tail` - Get the last element(s) from the list
- `POST /list` - Add items to the list
- `GET /list` - Get the entire list
- `DELETE /list` - Clear the list

## Available Commands

Run `make help` or `make` to see all available commands:

- `make install` - Install Python dependencies
- `make local-run` - Run API locally on port 8000
- `make test` - Run tests
- `make init` - Initialize Terraform
- `make plan` - Plan Terraform changes
- `make apply` - Apply Terraform changes
- `make destroy` - Destroy Terraform infrastructure

## Documentation

- [TERRAFORM_INFRASTRUCTURE.md](TERRAFORM_INFRASTRUCTURE.md) - Infrastructure management
- [SERVERLESS_DEPLOYMENT.md](SERVERLESS_DEPLOYMENT.md) - Code deployment details

## License

[MIT](LICENSE)