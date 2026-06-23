resource "azurerm_resource_group" "vmrg" {
  for_each = var.vmconfig
  name     = each.value.rg_name
  location = each.value.location
}
resource "azurerm_storage_account" "vmstorage" {
  for_each                 = var.vmconfig
  name                     = each.value.storge_account_name
  resource_group_name      = azurerm_resource_group.vmrg[each.key].name
  location                 = each.value.location
  account_tier             = each.value.account_tier
  account_replication_type = each.value.replication_type
}
resource "azurerm_storage_container" "vmconatiner" {
  for_each              = var.vmconfig
  name                  = each.value.container_name
  storage_account_name  = azurerm_storage_account.vmstorage[each.key].name
  container_access_type = "private"
}
resource "azurerm_virtual_network" "vmvnet" {
  for_each            = var.vmconfig
  name                = each.value.vm_vnet
  resource_group_name = azurerm_resource_group.vmrg[each.key].name
  location            = each.value.location
  address_space       = [each.value.address_space]
}
resource "azurerm_subnet" "vmsubnet" {
  for_each             = var.vmconfig
  name                 = each.value.subnet_name
  virtual_network_name = azurerm_virtual_network.vmvnet[each.key].name
  resource_group_name  = azurerm_resource_group.vmrg[each.key].name
  address_prefixes     = [each.value.address_prefix]
}

resource "azurerm_network_interface" "vmnic" {
  for_each            = var.vmconfig
  name                = each.value.nic_name
  location            = each.value.location
  resource_group_name = azurerm_resource_group.vmrg[each.key].name
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.vmsubnet[each.key].id
    private_ip_address_allocation = "Dynamic"

  }
}

resource "azurerm_virtual_machine" "vm1" {
  for_each              = var.vmconfig
  name                  = each.value.vm_name
  location              = each.value.location
  resource_group_name   = azurerm_resource_group.vmrg[each.key].name
  network_interface_ids = [azurerm_network_interface.vmnic[each.key].id]
  vm_size               = each.value.vm_size

  storage_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "vmdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "vm1"
    admin_username = "adminuser"
    admin_password = "Admin@12345"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

