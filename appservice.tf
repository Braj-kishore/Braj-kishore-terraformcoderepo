#---------------------------------------------------
# Create app service plan
#---------------------------------------------------
resource "azurerm_app_service_plan" "appplan" {
  name                = "${var.app_service_plan_name}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = var.app_service_sku.tier
    size = var.app_service_sku.size
  }
  tags=var.tags
}
#----------------------------------------------------=
# create app service
#-------------------------------------------------------
resource "azurerm_app_service" "app" {
  count = "${length(var.appservice_name)}"
  name                = "${var.appservice_name[count.index]}-APP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.appplan.id

  dynamic "identity" {
    for_each=var.enable_system_managed_identity==true ? [1] : []
    content { 
      type="SystemAssigned"
      }  
  }
  
  site_config {
    dotnet_framework_version = "v4.0"
  }


  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.appinsights.instrumentation_key}"
  }

  tags=var.tags

  depends_on = [
    azurerm_app_service_plan.appplan,
    azurerm_application_insights.appinsights,
  ]
}

#--------------------------------------------------------------------
#create azure application insight
#--------------------------------------------------------------------
resource "azurerm_application_insights" "appinsights" {
  name                = "${var.application_insights}-appinsights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}