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
  project_name = "hello-world"
  
  additional_tags = {
    Owner      = "DevTeam"
    CostCenter = "Engineering"
  }
  
  enable_lock = false  # Set to true for production
}

module "storage_account" {
  source = "../../modules/storage-account"
  
  name                     = "helloworld${var.environment}"
  resource_group_name      = module.resource_group.name
  location                 = module.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  containers = ["uploads", "backups", "logs"]
  
  tags = {
    Environment = var.environment
    Project     = "hello-world"
    Owner       = "DevTeam"
  }
}

terraform {
  backend "azurerm" {
    # Configuration will be provided via -backend-config    
  }
}