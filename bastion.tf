/*
* Azure bastion was configured in order to test the connectivity between the virtual machines within the same virtual network.
* Alternatively, you can set up a virtual network gateway to connect to the virtual network.
*/

resource "azurerm_public_ip" "bastion" {
  name                = "bastion-pip-${local.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.virtual_network_config.base_cidr, 8, var.virtual_network_config.subnet_count + 1)]
}

resource "azurerm_bastion_host" "bastion" {
  name                = "bastion-${local.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags

  ip_configuration {
    name                 = "bastion-feip-${local.suffix}"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}