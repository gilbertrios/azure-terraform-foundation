terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

# Create the resource group
resource "azurerm_resource_group" "main" {
  name     = var.name
  location = var.location

  tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    },
    var.additional_tags
  )

  lifecycle {
    ignore_changes = [tags["CreatedAt"]]
  }
}

# Optional: Resource lock to prevent accidental deletion
resource "azurerm_management_lock" "resource_group_lock" {
  count      = var.enable_lock ? 1 : 0
  name       = "${var.name}-lock"
  scope      = azurerm_resource_group.main.id
  lock_level = "CanNotDelete"
  notes      = "Prevents accidental deletion of ${var.name}"
}