# Resource Group Module

This module creates an Azure Resource Group with standardized tags and optional resource locking.

## Features

- Creates an Azure Resource Group
- Applies standardized tags (Environment, Project, ManagedBy, CreatedAt)
- Supports additional custom tags
- Optional resource lock to prevent accidental deletion
- Follows Azure naming conventions

## Usage

```hcl
module "resource_group" {
  source = "../../modules/resource-group"
  
  name         = "rg-myapp-dev"
  location     = "East US"
  environment  = "dev"
  project_name = "myapp"
  
  additional_tags = {
    Owner       = "DevTeam"
    CostCenter  = "Engineering"
  }
  
  enable_lock = true
}
```

## Requirements

| Name | Version |
|------|---------|
| azurerm | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name of the resource group | `string` | n/a | yes |
| location | Azure region | `string` | `"East US"` | no |
| environment | Environment name | `string` | n/a | yes |
| project_name | Name of the project | `string` | `"hello-world"` | no |
| additional_tags | Additional tags | `map(string)` | `{}` | no |
| enable_lock | Enable resource lock | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the resource group |
| name | The name of the resource group |
| location | The location of the resource group |
| tags | The tags applied to the resource group |
| resource_group | The complete resource group object |