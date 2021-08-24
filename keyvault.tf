#--------------------------------------------------------------------------
# create key vault 
#---------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "vault" {
  name                        = var.keyvault_Name
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = false
  enabled_for_template_deployment= false
  sku_name = var.sku_name
  
  #Adding service principal to the access policy and granting key secret permission
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = var.key_permissions

    secret_permissions =var.secret_permissions

    storage_permissions = var.storage_permissions
  }
}

#----------------------------------------------------------------
#add secret to the key vault
#Here we are adding connection string of the sql database and access key of the storage account.
#----------------------------------------------------------------

resource "azurerm_key_vault_secret" "vault_secret" {
  for_each        = { for secret in concat(var.secrets,local.secrets) : secret.name => secret }
  key_vault_id    = azurerm_key_vault.vault.id
  name            = each.value.name
  value           = each.value.value
  content_type    = lookup(each.value, "content_type", null)
  not_before_date = lookup(each.value, "not_before_date", null)
  expiration_date = lookup(each.value, "expiration_date", null)
}

#-----------------------------------------------------------------------
#Adding serviceprincipal/user/group to access policy to key vault
#we are also adding manage managed identity of the fronted and backend webapp to the access policy of the key vault 
#so that using mangaged identity they can access the secrets for connecting sql data base and storage account.
#------------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "accesspolicy" {
  count        = length(local.access_policies)
  key_vault_id = azurerm_key_vault.vault.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = local.access_policies[count.index].object_id
  secret_permissions      = local.access_policies[count.index].secret_permissions
  key_permissions         = local.access_policies[count.index].key_permissions
  certificate_permissions = local.access_policies[count.index].certificate_permissions
  storage_permissions     = local.access_policies[count.index].storage_permissions
}