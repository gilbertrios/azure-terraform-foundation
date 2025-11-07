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

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
  
  tags = {
    Environment = var.environment
  }
}

terraform {
  backend "azurerm" {
    # Configuration will be provided via -backend-config
    
  }
}