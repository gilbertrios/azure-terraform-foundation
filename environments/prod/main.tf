terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.51.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "resource_group" {
  source = "../../modules/resource-group"
  
  name         = var.resource_group_name
  location     = var.location
  environment  = var.environment
  project_name = "azure-terraform-foundation"
  
  additional_tags = {
    Owner      = "ProdTeam"
    CostCenter = "Engineering"
  }
  
  enable_lock = false  # Set to true for production
}


terraform {
  backend "azurerm" {
    # Configuration will be provided via -backend-config
  }
}