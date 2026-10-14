# 02-azure/vmss-flex-zonal: the building layer.
# A Virtual Machine Scale Set in Flexible orchestration mode, spread across
# availability zones. When a scale set spans zones, the fault domain count is
# 1 and the zones do the spreading.
# Docs: https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-orchestration-modes

locals {
  tags = {
    project = "blast-radius-kit"
    layer   = "building"
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.prefix}-vmss"
  location = var.region
  tags     = local.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.41.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "this" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.41.1.0/24"]
}

resource "azurerm_orchestrated_virtual_machine_scale_set" "this" {
  name                        = "${var.prefix}-vmss"
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  sku_name                    = var.instance_size
  instances                   = var.instance_count
  zones                       = var.zones
  platform_fault_domain_count = 1
  # Best-effort balance lets scale-out continue if one zone is short on capacity.
  zone_balance = false
  tags         = local.tags

  os_profile {
    linux_configuration {
      admin_username                  = var.admin_username
      computer_name_prefix            = var.prefix
      disable_password_authentication = true

      admin_ssh_key {
        username   = var.admin_username
        public_key = var.ssh_public_key
      }
    }
  }

  network_interface {
    name    = "${var.prefix}-nic"
    primary = true

    ip_configuration {
      name      = "ipconfig1"
      primary   = true
      subnet_id = azurerm_subnet.this.id
    }
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
