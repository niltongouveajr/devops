terraform {
  required_version = ">=1.1.7"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=3.0.2"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.az_subscription
}
