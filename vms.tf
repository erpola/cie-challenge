resource "azurerm_availability_set" "avset" {
  name                = "avset-${local.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}


resource "azurerm_network_interface" "nic" {
  count               = local.vm_count
  name                = "nic-${local.suffix}-${count.index + 1}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[0].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "tls_private_key" "vm_ssh" {
  count     = local.vm_count
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "azurerm_linux_virtual_machine" "vm" {
  count               = local.vm_count
  name                = "vm-${local.suffix}-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  admin_username      = "adminuser"
  size                = "Standard_DS1_v2"
  location            = var.location
  tags                = local.tags

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.vm_ssh[count.index].public_key_openssh
  }

  availability_set_id   = azurerm_availability_set.avset.id
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 256
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "95_gen2"
    version   = "latest"
  }
}

// start of apache vm

resource "tls_private_key" "apache_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_network_interface" "apache_nic" {
  name                = "apache-nic-${local.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[2].id
    private_ip_address_allocation = "Dynamic"

  }
}

resource "azurerm_linux_virtual_machine" "apache" {
  name                = "apache-${local.suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  admin_username      = "adminuser"
  size                = "Standard_DS1_v2"
  tags                = local.tags

  network_interface_ids = [azurerm_network_interface.apache_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "9_5"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.apache_ssh.public_key_openssh
  }

  user_data = base64encode(<<-EOF
  #cloud-config
  runcmd:
  - dnf update -y
  - dnf install -y httpd
  - systemctl start httpd
  - systemctl enable httpd
  - sudo firewall-cmd --permanent --add-service=http
  - sudo firewall-cmd --reload
  - systemctl restart httpd
  EOF
  )
}
