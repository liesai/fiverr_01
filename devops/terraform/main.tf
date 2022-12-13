provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "dev" {
  name     = "dev"
  location = "Canada Central"
}

resource "azurerm_key_vault" "kv-mmi-1" {
  name                        = "kv-mmi-1"
  location                    = azurerm_resource_group.dev.location
  resource_group_name         = azurerm_resource_group.dev.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "Create"
    ]

    secret_permissions = [
      "set",
      "get",
      "delete",
      "purge",
      "recover"
    ]

    storage_permissions = [
      "Get",
    ]
  }
}



resource "azurerm_app_service_plan" "svcplan" {
  name                = "app-service-plan-mmi"
  location            = "Canada Central"
  resource_group_name = azurerm_resource_group.dev.name
  kind = "linux"
  reserved = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "appsvc" {
  name                = "app-service-python-mmi"
  location            = "canada central"
  resource_group_name = azurerm_resource_group.dev.name
  app_service_plan_id = azurerm_app_service_plan.svcplan.id


  site_config {
    python_version    = "3.4"
    scm_type          = "LocalGit"
    app_command_line  = "gunicorn --bind=0.0.0.0 --timeout 600 app:app"


  }
}