resource "azurerm_service_plan" "service_plan" {
  name                = "${var.deployment_name}-plan"
  resource_group_name = var.resource_group
  location            = var.location
  os_type             = "Linux"
  sku_name            = "P1v3"
}

resource "azurerm_linux_function_app" "application" {
  name                = "${var.deployment_name}-func"
  resource_group_name = var.resource_group
  location            = var.location

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  service_plan_id            = azurerm_service_plan.service_plan.id

  app_settings = {
    "DYNATRACE_URL"                  = var.dynatrace_url
    "DYNATRACE_ACCESS_KEY"           = var.dynatrace_access_key
    "REQUIRE_VALID_CERTIFICATE"      = var.require_valid_certificate
    "EVENTHUB_CONNECTION_STRING"     = var.event_hub_connection_string
    "EVENTHUB_NAME"                  = var.event_hub_name
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
}
