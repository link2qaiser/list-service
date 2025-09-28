# ListService API - Makefile

.PHONY: help install local-run test init plan apply destroy

help:
	@echo "ListService API Commands:"
	@echo ""
	@echo "  install    - Install Python dependencies"
	@echo "  local-run  - Run API locally on port 8000"
	@echo "  test       - Run tests"
	@echo "  init       - Initialize Terraform"
	@echo "  plan       - Plan Terraform changes"
	@echo "  apply      - Apply Terraform changes"
	@echo "  destroy    - Destroy Terraform infrastructure"

# Local development
install:
	cd app && pip install -r requirements.txt

local-run:
	@echo "Starting ListService API at http://localhost:8000"
	@echo "Documentation at http://localhost:8000/docs"
	cd app && python main.py

test:
	cd app && python -m pytest tests/

# Terraform commands (assumes you're in dev environment)
init:
	cd environments/dev && terraform init

plan:
	cd environments/dev && terraform plan

apply:
	cd environments/dev && terraform apply

destroy:
	cd environments/dev && terraform destroy