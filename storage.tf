#-----------------------------------------------------------------
# create storage account
#-----------------------------------------------------------------
resource "azurerm_storage_account" "storage" {
  name                     = var.storageaccountname
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

#------------------------------------------------------------------------
# create multiple container
#-------------------------------------------------------------------------

resource "azurerm_storage_container" "storagecontainer" {
  for_each = {for container in var.containers: container.name => container}
  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = each.value.container_access_type
}