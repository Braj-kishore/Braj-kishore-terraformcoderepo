#-------------------------------------------------
# Create a resource group
#--------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

locals {
  secrets= [
    {name="Storage-AccessKey", value=azurerm_storage_account.storage.primary_access_key},
    {name="sql-password", value=random_password.rpassword.result},
    {name="sql-connectionstring", value= "Server=tcp:${azurerm_sql_server.sql.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.db.name};Persist Security Info=False;User ID=${var.admin_username == null ? "sqladmin" : var.admin_username};Password=${random_password.rpassword.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"}
    ]
  access_policies=concat(
    [
      {object_id="${azurerm_app_service.app[0].identity.0.principal_id}",secret_permissions=["Get",],certificate_permissions=[], key_permissions=[],storage_permissions=[] },
      {object_id="${azurerm_app_service.app[1].identity.0.principal_id}",secret_permissions=["Get",],certificate_permissions=[], key_permissions=[],storage_permissions=[] }
    ],var.access_policies) 
  
}








