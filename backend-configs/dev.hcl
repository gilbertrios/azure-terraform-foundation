terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-shared-infra"
    storage_account_name = "statesharedinfrajyzjo0l2"
    container_name       = "tfstate"
    key                  = "environments/dev/terraform.tfstate"
  }
}