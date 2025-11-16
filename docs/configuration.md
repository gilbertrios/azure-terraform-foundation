# Configuration Guide

This guide covers how to configure the Azure Terraform Foundation for your environment.

## Prerequisites

Before you begin, ensure you have:

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure subscription with appropriate permissions
- Git

## Authentication

### Local Development

For local development, authenticate using the Azure CLI:

```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "your-subscription-id"

# Verify your account
az account show
```

### Environment Variables

Set these environment variables for local Terraform execution:

```bash
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
```

You can add these to your shell profile (`.bashrc`, `.zshrc`) or use a `.env` file.

### GitHub Actions (CI/CD)

Configure these secrets in your GitHub repository:

1. Navigate to **Settings** > **Secrets and variables** > **Actions**
2. Add the following repository secrets:
   - `ARM_CLIENT_ID`
   - `ARM_CLIENT_SECRET`
   - `ARM_SUBSCRIPTION_ID`
   - `ARM_TENANT_ID`

#### Creating a Service Principal

```bash
# Create service principal
az ad sp create-for-rbac \
  --name "terraform-cicd" \
  --role Contributor \
  --scopes /subscriptions/{subscription-id}

# Output will contain:
# - appId (ARM_CLIENT_ID)
# - password (ARM_CLIENT_SECRET)
# - tenant (ARM_TENANT_ID)
```

## Backend Configuration

### Azure Storage Account Setup

The backend configuration uses Azure Storage for remote state. You need to create:

1. **Resource Group**: To contain the storage account
2. **Storage Account**: For state files
3. **Storage Container**: To store state blobs

```bash
# Set variables
RESOURCE_GROUP_NAME="rg-terraform-state"
STORAGE_ACCOUNT_NAME="sttfstate$(date +%s)"  # Must be globally unique
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

# Create container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME
```

### Backend Configuration Files

Update `backend-configs/dev.hcl` and `backend-configs/prod.hcl`:

```hcl
storage_account_name = "your-storage-account-name"
container_name       = "tfstate"
key                  = "dev.terraform.tfstate"  # or prod.terraform.tfstate
resource_group_name  = "rg-terraform-state"
```

## Environment Variables

### Development Environment

Edit `environments/dev/terraform.tfvars`:

```hcl
resource_group_name = "rg-myapp-dev"
location            = "East US"
environment         = "dev"
project_name        = "azure-terraform-foundation"

tags = {
  Environment = "Development"
  ManagedBy   = "Terraform"
  Project     = "azure-terraform-foundation"
}
```

### Production Environment

Edit `environments/prod/terraform.tfvars`:

```hcl
resource_group_name = "rg-myapp-prod"
location            = "East US"
environment         = "prod"
project_name        = "azure-terraform-foundation"

tags = {
  Environment = "Production"
  ManagedBy   = "Terraform"
  Project     = "azure-terraform-foundation"
}
```

## Module Configuration

### Resource Group Module

The resource group module accepts these variables:

```hcl
module "resource_group" {
  source = "../../modules/resource-group"
  
  name         = "rg-myapp-dev"
  location     = "East US"
  environment  = "dev"
  project_name = "azure-terraform-foundation"
  
  additional_tags = {
    Owner      = "DevTeam"
    CostCenter = "Engineering"
  }
  
  enable_lock = false  # Set to true for production
}
```

#### Available Variables

- **name** (required): Resource group name
- **location** (required): Azure region
- **environment** (required): Environment identifier (dev, prod)
- **project_name** (required): Project name for tagging
- **additional_tags** (optional): Custom tags
- **enable_lock** (optional): Enable resource lock (default: false)

## Validation

After configuration, validate your setup:

```bash
# Navigate to environment
cd environments/dev

# Initialize Terraform
terraform init -backend-config=../../backend-configs/dev.hcl

# Validate configuration
terraform validate

# Check formatting
terraform fmt -check -recursive

# Run a plan
terraform plan
```

## Troubleshooting

### Authentication Issues

If you see authentication errors:

```bash
# Verify Azure CLI login
az account show

# Check environment variables
echo $ARM_CLIENT_ID
echo $ARM_SUBSCRIPTION_ID
echo $ARM_TENANT_ID

# Re-authenticate
az logout
az login
```

### Backend State Issues

If you encounter state locking issues:

```bash
# Check for state locks
az storage blob list \
  --account-name $STORAGE_ACCOUNT_NAME \
  --container-name $CONTAINER_NAME

# Force unlock (use cautiously)
terraform force-unlock <lock-id>
```

### Module Not Found

If modules can't be found:

```bash
# Re-initialize to download modules
terraform init -upgrade

# Verify module paths in main.tf
```

## Best Practices

1. **Never commit secrets**: Use `.gitignore` to exclude sensitive files
2. **Use remote state**: Always configure remote backend for team collaboration
3. **Enable state locking**: Prevents concurrent modifications
4. **Tag resources**: Consistent tagging helps with cost management and organization
5. **Environment isolation**: Keep dev/prod configurations separate
6. **Version pinning**: Specify Terraform and provider versions
