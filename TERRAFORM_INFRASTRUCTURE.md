# Terraform Infrastructure Management

This document explains how to manage the AWS infrastructure for the With Secure API using Terraform.

## Infrastructure Deployment

Infrastructure is managed **manually** from your local machine using Terraform. The CI/CD pipeline only handles code updates.

### Initial Setup

1. Initialize and deploy infrastructure:

```bash
make init     # Initialize Terraform
make plan     # Review what will be created
make apply    # Create the infrastructure
```

### Post-Deployment Steps

4. After deployment, note the output values, especially:

   - Lambda function name
   - Lambda role ARN
   - API Gateway endpoint

5. Store the Lambda role ARN in SSM Parameter Store so the CI/CD pipeline can access it:

```bash
aws ssm put-parameter \
    --name "/lambda-with-secure/dev/role-arn" \
    --type "String" \
    --value "arn:aws:iam::123456789012:role/dev-with-secure-role" \
    --overwrite
```

### Updating Infrastructure

When you need to make changes to the infrastructure:

```bash
make plan    # Review changes
make apply   # Apply changes
```

### Destroying Infrastructure

⚠️ **Use with extreme caution!**

```bash
make destroy   # Destroy all infrastructure
```

### Available Make Commands

Run `make help` to see all available commands:

- `make init` - Initialize Terraform
- `make plan` - Plan Terraform changes  
- `make apply` - Apply Terraform changes
- `make destroy` - Destroy Terraform infrastructure
- `make install` - Install Python dependencies
- `make local-run` - Run API locally
- `make test` - Run tests

### Important Notes

- **Never** run `terraform destroy` in production without a backup plan
- Always use the same region (us-east-2) for all environments
- Remember to update all environments when making structural changes
- Use `make plan` before `make apply` to review changes

## Resources Created

Terraform creates the following resources:

- Lambda function with basic code
- API Gateway HTTP API
- CloudWatch log groups
- IAM roles and policies
- CloudWatch alarms and dashboard
- Secrets Manager secret

## Folder Structure

```
├── environments/
│   ├── dev/        # Development environment
│   ├── stage/      # Staging environment
│   └── prod/       # Production environment
└── modules/
    └── lambda_api/ # Reusable module for Lambda API
```

## Manual Operations

Some operations that need to be done manually:

1. Initial infrastructure deployment for each environment
2. Infrastructure updates
3. Initial role ARN configuration in SSM Parameter Store
4. Creating and managing any additional resources not in Terraform

## Environment-Specific Deployment

### Development Environment
```bash
make init
make apply
```

### Staging Environment
```bash
# First navigate to staging
cd environments/stage
make init
make apply
```

### Production Environment
```bash
# First navigate to production  
cd environments/prod
make init
make apply
```

## Connecting to CI/CD

The GitHub Actions workflow will:

1. Only update Lambda code and dependencies, not infrastructure
2. Use the Serverless Framework to deploy to the Lambda functions created by Terraform
3. Rely on the IAM roles created by Terraform

## Troubleshooting

### Common Issues

1. **Large deployment package error**: If you get a "Request must be smaller than 70167211 bytes" error, the Lambda layer approach should handle this automatically.

2. **Permission errors**: Ensure your AWS CLI is configured with appropriate permissions.

3. **State lock issues**: If Terraform state is locked, wait a few minutes or investigate the lock in your backend.

### Getting Help

- Run `make help` for available commands
- Use `make plan` to preview changes before applying
- Check AWS CloudWatch logs for Lambda function iss