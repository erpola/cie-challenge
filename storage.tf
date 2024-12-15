resource "azurerm_storage_account" "storage" {
  name                     = substr(replace("sa${local.hex}${local.suffix}", "-", ""), 0, 24)
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [for subnet in azurerm_subnet.subnet : subnet.id]
  }
}