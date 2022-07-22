terraform {
  required_version = ">=1.2.1"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=3.8.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.az_subscription
}
