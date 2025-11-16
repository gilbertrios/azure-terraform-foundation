# Setup Guide

Complete step-by-step guide to get Azure Terraform Foundation up and running.

## Step 1: Prerequisites

Install required tools:

### Terraform
```bash
# macOS
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verify installation
terraform -version
```

### Azure CLI
```bash
# macOS
brew update && brew install azure-cli

# Verify installation
az --version
```

### Git
```bash
# macOS
brew install git

# Verify installation
git --version
```

## Step 2: Clone Repository

```bash
# Clone the repository
git clone https://github.com/gilbertrios/azure-terraform-foundation.git

# Navigate to the project
cd azure-terraform-foundation
```

## Step 3: Azure Authentication

### Login to Azure
```bash
az login
```

### Set Active Subscription
```bash
# List subscriptions
az account list --output table

# Set subscription
az account set --subscription "your-subscription-id"

# Verify
az account show
```

## Step 4: Create Service Principal (for CI/CD)

```bash
# Create service principal with Contributor role
az ad sp create-for-rbac \
  --name "terraform-cicd-sp" \
  --role Contributor \
  --scopes /subscriptions/{your-subscription-id} \
  --json-auth

# Save the output - you'll need:
# - appId (ARM_CLIENT_ID)
# - password (ARM_CLIENT_SECRET)
# - tenant (ARM_TENANT_ID)
```

## Step 5: Setup Remote State Storage

```bash
# Set variables
RESOURCE_GROUP_NAME="rg-terraform-state"
STORAGE_ACCOUNT_NAME="sttfstate$(date +%s)"
CONTAINER_NAME="tfstate"
LOCATION="eastus"

# Create resource group
az group create \
  --name $RESOURCE_GROUP_NAME \
  --location $LOCATION

# Create storage account
az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  --sku Standard_LRS \
  --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --query '[0].value' -o tsv)

# Create container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --account-key $ACCOUNT_KEY

echo "Storage Account Name: $STORAGE_ACCOUNT_NAME"
```

## Step 6: Configure Backend

Update `backend-configs/dev.hcl`:

```hcl
storage_account_name = "your-storage-account-name"
container_name       = "tfstate"
key                  = "dev.terraform.tfstate"
resource_group_name  = "rg-terraform-state"
```

Update `backend-configs/prod.hcl`:

```hcl
storage_account_name = "your-storage-account-name"
container_name       = "tfstate"
key                  = "prod.terraform.tfstate"
resource_group_name  = "rg-terraform-state"
```

## Step 7: Configure Environment Variables

### For Local Development

```bash
# Add to ~/.bashrc or ~/.zshrc
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"

# Reload shell configuration
source ~/.bashrc  # or source ~/.zshrc
```

## Step 8: Initialize Development Environment

```bash
# Navigate to dev environment
cd environments/dev

# Initialize Terraform
terraform init -backend-config=../../backend-configs/dev.hcl

# Validate configuration
terraform validate

# Review the plan
terraform plan

# Apply infrastructure
terraform apply
```

## Step 9: Configure GitHub Secrets (for CI/CD)

1. Go to your GitHub repository
2. Navigate to **Settings** > **Secrets and variables** > **Actions**
3. Click **New repository secret** and add:
   - Name: `ARM_CLIENT_ID`, Value: `<your-client-id>`
   - Name: `ARM_CLIENT_SECRET`, Value: `<your-client-secret>`
   - Name: `ARM_SUBSCRIPTION_ID`, Value: `<your-subscription-id>`
   - Name: `ARM_TENANT_ID`, Value: `<your-tenant-id>`

## Step 10: Test CI/CD Pipeline

```bash
# Create a test branch
git checkout -b test/cicd-validation

# Make a small change
echo "# Test" >> environments/dev/terraform.tfvars

# Commit and push
git add environments/dev/terraform.tfvars
git commit -m "test: validate CI/CD pipeline"
git push origin test/cicd-validation

# Create pull request on GitHub
# The workflow will automatically run terraform plan
```

## Verification Checklist

- [ ] Terraform installed and version >= 1.0
- [ ] Azure CLI installed and authenticated
- [ ] Service principal created with appropriate permissions
- [ ] Remote state storage account created
- [ ] Backend configuration files updated
- [ ] Environment variables configured (local and GitHub)
- [ ] Development environment successfully deployed
- [ ] CI/CD pipeline runs on pull request
- [ ] Terraform plan appears as PR comment

## Next Steps

- Review [Configuration Guide](configuration.md) for advanced settings
- Explore [Commands Reference](commands-reference.md) for common operations
- Read [Repository Structure](repository-structure.md) to understand the layout
- Check [CI/CD Pipeline Documentation](cicd-pipeline.md) for workflow details

## Troubleshooting

### Issue: "Backend initialization required"
```bash
terraform init -reconfigure -backend-config=../../backend-configs/dev.hcl
```

### Issue: "Permission denied"
```bash
# Verify service principal has Contributor role
az role assignment list --assignee <client-id> --output table
```

### Issue: "State lock"
```bash
# Check locks
az storage blob list \
  --account-name <storage-account> \
  --container-name tfstate

# Force unlock if necessary
terraform force-unlock <lock-id>
```

### Issue: "Module not found"
```bash
# Re-initialize with upgrade
terraform init -upgrade
```

## Support

For issues or questions:
- Check [GitHub Issues](https://github.com/gilbertrios/azure-terraform-foundation/issues)
- Review [Documentation](../README.md#-resources)
- Contact: gilbertrios@hotmail.com
