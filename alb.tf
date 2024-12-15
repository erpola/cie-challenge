resource "azurerm_public_ip" "lb_pip" {
  name                = "lb-pip-${local.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "lb-pip-${local.suffix}"
  tags                = local.tags
}

resource "azurerm_lb" "lb" {
  name                = "lb-${local.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  tags                = local.tags

  frontend_ip_configuration {
    name                 = "lb-feip-${local.suffix}"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

resource "azurerm_lb_probe" "lb_probe" {
  name                = "apache-probe-${local.suffix}"
  loadbalancer_id     = azurerm_lb.lb.id
  port                = 80
  protocol            = "Http"
  request_path        = "/.noindex.html" // probes the default page
  interval_in_seconds = 5
}

resource "azurerm_lb_backend_address_pool" "lb_be_pool" {
  name            = "lb-bepool-${local.suffix}"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "apache_assoc" {
  ip_configuration_name   = azurerm_network_interface.apache_nic.ip_configuration[0].name
  network_interface_id    = azurerm_network_interface.apache_nic.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_be_pool.id
}

resource "azurerm_lb_rule" "lb_rule" {
  name                           = "http"
  probe_id                       = azurerm_lb_probe.lb_probe.id
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_be_pool.id]
}
