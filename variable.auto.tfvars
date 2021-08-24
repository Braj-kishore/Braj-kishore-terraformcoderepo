resource_group_name="APPResourceGroup"

resource_group_location="Southeast Asia"

app_service_plan_name="abcappplan"

appservice_name=["abcFronted","abcBackend"]

enable_system_managed_identity=true

storageaccountname="storagedev123"

application_insights="abcdapplication"

containers=[
    {
        "name"="testconatiner1"
        container_access_type = "private"
    },
    {
        "name"="testconatiner2"
        container_access_type = "private"
    }
    ]

    keyvault_Name="keyvaultDev"

    key_permissions=[
        "Get",
        "Create",
        "Delete",
        "Import",
        "List",
        "Purge",
        "Recover",
      ]
    secret_permissions=[
      "Get",
      "Set",
      "Delete",
      "List",
      "Purge",
      "Recover",
    ]

    sqlserver_name="abc-sqlserver"

    subnet_prefix=[
    {
      ip      = "10.0.1.0/24"
      name     = "subnet-1"
      service_endpoints=["Microsoft.Storage","Microsoft.Sql","Microsoft.Web"]

    },
    {
      ip      = "10.0.2.0/24"
      name     = "subnet-2"
      service_endpoints=["Microsoft.Web"]
      delegation={
        name="media-delegation"
        service_delegation={
          name="Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
          }
      }
    }
   ]


  