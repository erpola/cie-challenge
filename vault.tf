resource "azurerm_key_vault" "kv" {
  name                      = substr("kv-${local.hex}-${local.suffix}", 0, 24)
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = "standard"
  enable_rbac_authorization = true
  tags                      = local.tags
}

resource "azurerm_key_vault_secret" "apache" {
  key_vault_id = azurerm_key_vault.kv.id
  name         = "${azurerm_linux_virtual_machine.apache.name}-ssh-key"
  value        = tls_private_key.apache_ssh.private_key_pem
}

resource "azurerm_key_vault_secret" "vm" {
  count        = local.vm_count
  key_vault_id = azurerm_key_vault.kv.id
  name         = "${azurerm_linux_virtual_machine.vm[count.index].name}-ssh-key"
  value        = tls_private_key.vm_ssh[count.index].private_key_pem
}