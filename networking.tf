resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${local.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.virtual_network_config.base_cidr]
  tags                = local.tags
}

resource "azurerm_subnet" "subnet" {
  count                = var.virtual_network_config.subnet_count
  name                 = "snet-${local.suffix}-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.virtual_network_config.base_cidr, 8, count.index)]
  service_endpoints    = ["Microsoft.Storage"]
}