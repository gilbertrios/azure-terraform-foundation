# Commands Reference

Quick reference for common Terraform and Azure CLI commands used in this project.

## Terraform Commands

### Initialization

```bash
# Initialize with backend configuration
terraform init -backend-config=../../backend-configs/dev.hcl

# Re-initialize (useful after backend changes)
terraform init -reconfigure

# Upgrade providers and modules
terraform init -upgrade

# Initialize without backend
terraform init -backend=false
```

### Planning

```bash
# Create execution plan
terraform plan

# Save plan to file
terraform plan -out=tfplan

# Target specific resource
terraform plan -target=module.resource_group

# View plan with detailed output
terraform plan -json
```

### Applying

```bash
# Apply changes (with confirmation)
terraform apply

# Apply saved plan
terraform apply tfplan

# Apply without confirmation (use with caution)
terraform apply -auto-approve

# Apply targeting specific resource
terraform apply -target=module.resource_group
```

### Destroying

```bash
# Destroy all resources (with confirmation)
terraform destroy

# Destroy without confirmation (use with caution)
terraform destroy -auto-approve

# Destroy specific resource
terraform destroy -target=module.resource_group
```

### State Management

```bash
# List resources in state
terraform state list

# Show resource details
terraform state show module.resource_group.azurerm_resource_group.main

# Remove resource from state (doesn't delete actual resource)
terraform state rm module.resource_group

# Move resource in state
terraform state mv module.old_name module.new_name

# Pull remote state
terraform state pull > terraform.tfstate

# Push local state (dangerous - use carefully)
terraform state push terraform.tfstate
```

### Workspace Management

```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new staging

# Switch workspace
terraform workspace select dev

# Delete workspace
terraform workspace delete staging
```

### Validation & Formatting

```bash
# Validate configuration
terraform validate

# Format code
terraform fmt

# Format recursively
terraform fmt -recursive

# Check if formatting is needed
terraform fmt -check

# Format and show diff
terraform fmt -diff
```

### Output

```bash
# Show all outputs
terraform output

# Show specific output
terraform output resource_group_id

# Output in JSON format
terraform output -json
```

### Import

```bash
# Import existing resource
terraform import module.resource_group.azurerm_resource_group.main /subscriptions/{sub-id}/resourceGroups/my-rg
```

### Locking

```bash
# Force unlock state (use with extreme caution)
terraform force-unlock <lock-id>
```

## Azure CLI Commands

### Authentication

```bash
# Login
az login

# Login with service principal
az login --service-principal \
  --username $ARM_CLIENT_ID \
  --password $ARM_CLIENT_SECRET \
  --tenant $ARM_TENANT_ID

# Logout
az logout

# Show current account
az account show

# List all subscriptions
az account list --output table

# Set subscription
az account set --subscription "subscription-id"
```

### Resource Groups

```bash
# List resource groups
az group list --output table

# Create resource group
az group create --name rg-myapp-dev --location eastus

# Delete resource group
az group delete --name rg-myapp-dev --yes

# Show resource group
az group show --name rg-myapp-dev
```

### Storage (for Backend State)

```bash
# Create storage account
az storage account create \
  --name mystorageaccount \
  --resource-group rg-terraform-state \
  --location eastus \
  --sku Standard_LRS

# List storage accounts
az storage account list --output table

# Get storage account keys
az storage account keys list \
  --resource-group rg-terraform-state \
  --account-name mystorageaccount

# Create container
az storage container create \
  --name tfstate \
  --account-name mystorageaccount

# List blobs (state files)
az storage blob list \
  --account-name mystorageaccount \
  --container-name tfstate \
  --output table
```

### Service Principal

```bash
# Create service principal
az ad sp create-for-rbac \
  --name "terraform-cicd" \
  --role Contributor \
  --scopes /subscriptions/{subscription-id}

# List service principals
az ad sp list --display-name terraform-cicd

# Show service principal
az ad sp show --id <app-id>

# Delete service principal
az ad sp delete --id <app-id>

# Assign role
az role assignment create \
  --assignee <app-id> \
  --role Contributor \
  --scope /subscriptions/{subscription-id}
```

### Resources

```bash
# List all resources
az resource list --output table

# List resources in resource group
az resource list --resource-group rg-myapp-dev --output table

# Show resource
az resource show --ids <resource-id>

# Delete resource
az resource delete --ids <resource-id>
```

### Tags

```bash
# List tags
az tag list

# Add tag to resource group
az group update \
  --name rg-myapp-dev \
  --tags Environment=Development Project=MyApp
```

## GitHub CLI Commands

### Workflow Management

```bash
# List workflows
gh workflow list

# Trigger workflow manually
gh workflow run terraform.yml

# View workflow runs
gh run list --workflow=terraform.yml

# Watch workflow execution
gh run watch

# View run details
gh run view <run-id>

# Download run logs
gh run download <run-id>
```

### Pull Requests

```bash
# Create PR
gh pr create --title "Add new resource" --body "Description"

# List PRs
gh pr list

# View PR
gh pr view <pr-number>

# Checkout PR
gh pr checkout <pr-number>

# Merge PR
gh pr merge <pr-number>
```

### Secrets

```bash
# List secrets
gh secret list

# Set secret
gh secret set ARM_CLIENT_ID

# Delete secret
gh secret delete ARM_CLIENT_ID
```

## Common Workflows

### Deploy to Dev Environment

```bash
cd environments/dev
terraform init -backend-config=../../backend-configs/dev.hcl
terraform plan
terraform apply
```

### Deploy to Prod Environment

```bash
cd environments/prod
terraform init -backend-config=../../backend-configs/prod.hcl
terraform plan
terraform apply
```

### Update Module

```bash
# Make changes to module
cd modules/resource-group
# Edit files...

# Test in dev
cd ../../environments/dev
terraform init -upgrade
terraform plan
terraform apply
```

### Migrate State

```bash
# Pull current state
terraform state pull > backup.tfstate

# Modify backend configuration
# ...

# Re-initialize with new backend
terraform init -migrate-state
```

### Clean Up

```bash
# Remove .terraform directory
rm -rf .terraform

# Remove plan files
rm -f tfplan

# Remove state backup files
rm -f terraform.tfstate.backup
```

## Environment Variables

### Set for Local Development

```bash
# Add to ~/.bashrc or ~/.zshrc
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"

# Terraform logging
export TF_LOG=DEBUG
export TF_LOG_PATH="./terraform.log"
```

### Unset

```bash
unset ARM_CLIENT_ID
unset ARM_CLIENT_SECRET
unset ARM_SUBSCRIPTION_ID
unset ARM_TENANT_ID
unset TF_LOG
unset TF_LOG_PATH
```

## Tips & Tricks

### Create Alias

```bash
# Add to ~/.bashrc or ~/.zshrc
alias tf='terraform'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfi='terraform init'
alias tfv='terraform validate'
alias tff='terraform fmt -recursive'
```

### Use Terraform Console

```bash
# Interactive console to test expressions
terraform console

# Examples:
> module.resource_group.resource_group_name
> var.environment
> local.common_tags
```

### View Graph

```bash
# Generate dependency graph
terraform graph | dot -Tpng > graph.png
```

### Debug Mode

```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform plan

# Log to file
export TF_LOG_PATH="./terraform.log"
terraform plan
```

## Additional Resources

- [Terraform CLI Documentation](https://www.terraform.io/cli/commands)
- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)
- [GitHub CLI Documentation](https://cli.github.com/manual/)
