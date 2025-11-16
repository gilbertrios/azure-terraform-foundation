# CI/CD Pipeline Documentation

Complete guide to the automated CI/CD pipeline for Azure Terraform Foundation.

## Overview

The GitHub Actions workflow automates Terraform deployment with:
- ✅ **Pull Request Validation**: Runs `terraform plan` on PRs
- ✅ **Automatic Deployment**: Applies changes on merge to main
- ✅ **Environment Isolation**: Separate dev/prod workflows
- ✅ **PR Comments**: Plan output posted to pull requests
- ✅ **Security**: Uses GitHub secrets for credentials

## Workflow File

Location: `.github/workflows/terraform.yml`

## Triggers

The pipeline runs on:

### Pull Requests
```yaml
pull_request:
  paths:
    - 'environments/**'
    - '.github/workflows/terraform.yml'
```

Runs `terraform plan` and posts results as PR comment.

### Push to Main
```yaml
push:
  branches:
    - main
  paths:
    - 'environments/**'
    - '.github/workflows/terraform.yml'
```

Runs `terraform apply` to deploy infrastructure.

## Pipeline Stages

### Stage 1: Detect Changes

Determines which environments have changed using Git diff.

**Outputs**:
- `dev`: `true` if dev environment changed
- `prod`: `true` if prod environment changed

### Stage 2: Terraform Plan (PRs only)

Runs for each changed environment in parallel.

**Steps**:
1. Checkout code
2. Setup Terraform
3. Configure Azure credentials
4. Initialize Terraform with backend
5. Run `terraform plan`
6. Post plan output to PR as comment

**Environment Matrix**:
```yaml
strategy:
  matrix:
    environment: [dev, prod]
```

### Stage 3: Terraform Apply (Main branch only)

Deploys infrastructure to changed environments.

**Steps**:
1. Checkout code
2. Setup Terraform
3. Configure Azure credentials
4. Initialize Terraform with backend
5. Run `terraform apply -auto-approve`

**Environment Protection**:
- Dev: Auto-deploys
- Prod: Requires manual approval (recommended)

## Environment Variables

### Required Secrets

Configure in GitHub repository settings:

| Secret | Description |
|--------|-------------|
| `ARM_CLIENT_ID` | Azure service principal application ID |
| `ARM_CLIENT_SECRET` | Azure service principal password |
| `ARM_SUBSCRIPTION_ID` | Azure subscription ID |
| `ARM_TENANT_ID` | Azure Active Directory tenant ID |

### Workflow Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `environment` | Target environment | `dev`, `prod` |
| `working-directory` | Terraform working directory | `environments/dev` |
| `backend-config` | Backend configuration file | `backend-configs/dev.hcl` |

## Job Details

### Plan Job

```yaml
name: Terraform Plan
runs-on: ubuntu-latest
if: github.event_name == 'pull_request'
```

**Responsibilities**:
- Validate Terraform configuration
- Generate execution plan
- Identify changes before merge
- Provide visibility via PR comments

### Apply Job

```yaml
name: Terraform Apply
runs-on: ubuntu-latest
if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```

**Responsibilities**:
- Deploy infrastructure changes
- Update remote state
- Provision Azure resources

## PR Comment Format

The workflow posts plan results to PRs:

````markdown
## Terraform Plan - dev

```hcl
Terraform will perform the following actions:

  # module.resource_group.azurerm_resource_group.main will be created
  + resource "azurerm_resource_group" "main" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "rg-myapp-dev"
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```
````

## Environment Protection

### Development Environment

- **Auto-deployment**: Enabled
- **Approval**: Not required
- **Branch protection**: Optional

### Production Environment

Configure environment protection rules:

1. Go to **Settings** > **Environments** > **prod**
2. Enable **Required reviewers**
3. Add authorized reviewers
4. Enable **Wait timer** (optional delay)
5. Configure **Deployment branches** to `main` only

## Manual Workflow Dispatch

Trigger workflows manually:

### Using GitHub UI

1. Go to **Actions** tab
2. Select **Terraform** workflow
3. Click **Run workflow**
4. Select branch
5. Click **Run workflow**

### Using GitHub CLI

```bash
# Trigger workflow
gh workflow run terraform.yml

# Trigger with inputs (if configured)
gh workflow run terraform.yml -f environment=dev
```

## Monitoring & Debugging

### View Workflow Runs

```bash
# List recent runs
gh run list --workflow=terraform.yml

# View specific run
gh run view <run-id>

# Watch active run
gh run watch
```

### Download Logs

```bash
# Download run logs
gh run download <run-id>
```

### Common Issues

#### Issue: "Error acquiring state lock"

**Cause**: Another process has the state lock

**Solution**:
```bash
# Wait for other operation to complete, or force unlock
terraform force-unlock <lock-id>
```

#### Issue: "Authentication failed"

**Cause**: Invalid or expired credentials

**Solution**:
1. Verify GitHub secrets are set correctly
2. Check service principal permissions
3. Ensure service principal is not expired

#### Issue: "Backend initialization failed"

**Cause**: Backend storage not accessible

**Solution**:
1. Verify storage account exists
2. Check service principal has Storage Blob Data Contributor role
3. Verify backend configuration in `.hcl` files

## Best Practices

### 1. Always Review Plans

- Review terraform plan output in PRs before merging
- Understand all proposed changes
- Check for unintended deletions

### 2. Use Branch Protection

Configure branch protection on `main`:
- Require PR reviews
- Require status checks to pass
- Prevent force pushes

### 3. Environment Isolation

- Keep dev and prod completely separate
- Use different service principals for each environment
- Never share state files between environments

### 4. State Lock Handling

- Never force unlock unless absolutely necessary
- Coordinate with team before unlocking
- Investigate why lock exists before removing

### 5. Credential Rotation

- Regularly rotate service principal secrets
- Update GitHub secrets when credentials change
- Use short-lived credentials when possible

### 6. Cost Management

- Set up Azure Cost Management alerts
- Tag all resources for cost tracking
- Review resource usage regularly

## Advanced Configuration

### Matrix Strategy with Exclusions

```yaml
strategy:
  matrix:
    environment: [dev, staging, prod]
    exclude:
      - environment: staging  # Skip staging if not ready
```

### Conditional Steps

```yaml
- name: Apply with approval
  if: matrix.environment == 'prod'
  run: terraform apply
```

### Reusable Workflows

Create shared workflow for Terraform operations:

```yaml
# .github/workflows/terraform-reusable.yml
on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
```

Use in main workflow:

```yaml
jobs:
  deploy-dev:
    uses: ./.github/workflows/terraform-reusable.yml
    with:
      environment: dev
```

## Rollback Strategy

### Automatic Rollback via Git

```bash
# Revert last commit
git revert HEAD
git push origin main

# Pipeline will apply previous state
```

### Manual Rollback

```bash
# Checkout previous version
git checkout <previous-commit-hash> -- environments/prod/

# Commit and push
git commit -m "Rollback prod to previous state"
git push origin main
```

### State Rollback (Emergency)

```bash
# Pull state backup from Azure Storage
az storage blob download \
  --account-name <storage-account> \
  --container-name tfstate \
  --name prod.terraform.tfstate.backup \
  --file terraform.tfstate

# Push backup as current state (dangerous!)
terraform state push terraform.tfstate
```

## Notifications

### Slack Integration

Add to workflow:

```yaml
- name: Notify Slack
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Email Notifications

Configure in GitHub notification settings or use action:

```yaml
- name: Send Email
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 465
    username: ${{secrets.MAIL_USERNAME}}
    password: ${{secrets.MAIL_PASSWORD}}
    subject: Terraform Deployment Failed
    body: Check workflow run at ${{github.server_url}}/${{github.repository}}/actions/runs/${{github.run_id}}
```

## Security Considerations

1. **Never log sensitive data**: Avoid printing secrets in workflow logs
2. **Use OIDC**: Consider using OpenID Connect instead of long-lived secrets
3. **Audit trail**: All changes tracked via Git and GitHub Actions logs
4. **Least privilege**: Service principal should have minimal required permissions
5. **State encryption**: Enable encryption at rest for backend storage

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform Cloud Workflows](https://www.terraform.io/cloud-docs/run/ui)
- [Azure DevOps Terraform Tasks](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks)
