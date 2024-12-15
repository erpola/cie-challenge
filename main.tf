provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.suffix}"
  location = var.location
  tags     = local.tags
}

resource "random_bytes" "random" {
  length = 2
}

data "azurerm_client_config" "current" {}