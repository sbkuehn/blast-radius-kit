# 02-azure/availability-set: the rack layer.
# An availability set spreads VMs across fault domains (shared power and
# network switch) and update domains (planned maintenance waves).
# Docs: https://learn.microsoft.com/en-us/azure/virtual-machines/availability-set-overview

locals {
  tags = {
    project = "blast-radius-kit"
    layer   = "rack"
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.prefix}-avset"
  location = var.region
  tags     = local.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.40.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "this" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.40.1.0/24"]
}

resource "azurerm_availability_set" "this" {
  name                         = "${var.prefix}-avset"
  location                     = azurerm_resource_group.this.location
  resource_group_name          = azurerm_resource_group.this.name
  platform_fault_domain_count  = var.fault_domain_count
  platform_update_domain_count = var.update_domain_count
  # managed = true is the "Aligned" SKU: managed disks follow their VM's fault domain.
  managed = true
  tags    = local.tags
}

resource "azurerm_network_interface" "this" {
  count               = var.instance_count
  name                = "${var.prefix}-vm${count.index}-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  count                 = var.instance_count
  name                  = "${var.prefix}-vm${count.index}"
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  size                  = var.instance_size
  availability_set_id   = azurerm_availability_set.this.id
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.this[count.index].id]
  tags                  = local.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}
