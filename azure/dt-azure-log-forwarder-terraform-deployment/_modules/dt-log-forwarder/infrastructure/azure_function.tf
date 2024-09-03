resource "azurerm_service_plan" "this" {
  name                = "${var.deployment_name}-plan"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "P1v3"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_linux_function_app" "this" {
  name                = "${var.deployment_name}-func"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  service_plan_id            = azurerm_service_plan.this.id

  app_settings = {
    "DYNATRACE_URL" = var.dynatrace_url
    "DYNATRACE_ACCESS_KEY" = var.dynatrace_access_key
    "REQUIRE_VALID_CERTIFICATE" = var.require_valid_certificate
    "EVENTHUB_CONNECTION_STRING" = var.event_hub_connection_string
    "EVENTHUB_NAME" = var.event_hub_name
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
  }

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  identity {
    type = "SystemAssigned"
  }
  zip_deploy_file = local.zip_file

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}