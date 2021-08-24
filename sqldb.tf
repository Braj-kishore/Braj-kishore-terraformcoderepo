#-----------------------------------------------------------------------
# create Sql server and Sql data base
#-----------------------------------------------------------------------
resource "random_password" "rpassword" {
  length      = var.random_password_length
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special= 2
  special     = true
  override_special ="_%@!$"
}

#----------------------------------------------------------------------------------------------
#create storage account if var.enable_sql_server_extended_auditing_policy 
#|| var.enable_database_extended_auditing_policy == true
#-----------------------------------------------------------------------------------------------
resource "azurerm_storage_account" "storeacc" {
  count                     = var.enable_sql_server_extended_auditing_policy || var.enable_database_extended_auditing_policy == true ? 1 : 0
  name                      = var.storage_account_name_sql
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  tags                      = var.tags
}

resource "azurerm_sql_server" "sql" {
  name                         = format("%s-%s", var.sqlserver_name,var.environment)
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.admin_username == null ? "sqladmin" : var.admin_username
  administrator_login_password = var.admin_password == null ? random_password.rpassword.result : var.admin_password
  tags                         = var.tags

  dynamic "identity" {
    for_each = var.enable_system_managed_identity_sql == true ? [1] : [0]
    content {
      type = "SystemAssigned"
    }
  }
}

resource "azurerm_mssql_server_extended_auditing_policy" "auditingpolicy" {
  count                                   = var.enable_sql_server_extended_auditing_policy ? 1 : 0
  server_id                               = azurerm_sql_server.sql.id
  storage_endpoint                        = azurerm_storage_account.storeacc.0.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.storeacc.0.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.retention_days
}

resource "azurerm_sql_database" "db" {
  name                             = var.database_name
  resource_group_name              = azurerm_resource_group.rg.name
  location                         = azurerm_resource_group.rg.location
  server_name                      = azurerm_sql_server.sql.name
  edition                          = var.sql_database_edition
  tags                             = var.tags

  dynamic "extended_auditing_policy" {
    for_each=var.enable_database_extended_auditing_policy==true ? [1] :[]
    content {
      storage_endpoint                        = azurerm_storage_account.storeacc.primary_blob_endpoint
      storage_account_access_key              = azurerm_storage_account.storeacc.primary_access_key
      storage_account_access_key_is_secondary = true
      retention_in_days                       = var.retention_days
    }
  }

}