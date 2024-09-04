provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_to_deploy_logfw" {
  name     = "rg-${local.deployment_name}"
  location = local.location
}

module "application" {
  source = "./modules/infrastructure/function"
  deployment_name = local.deployment_name
  location = local.location
  dynatrace_url = local.dynatrace_url
  dynatrace_access_key = local.dynatrace_access_key
  event_hub_name = local.event_hub_name
  event_hub_connection_string = local.event_hub_connection_string
  require_valid_certificate = local.require_valid_certificate
  version_number = local.version_number
  resource_group = azurerm_resource_group.rg_to_deploy_logfw.name

  storage_account_name       = module.storage-blob.azurerm_storage_account_name
  storage_account_access_key = module.storage-blob.azurerm_storage_account_key
}

module "storage-blob" {
  source = "./modules/infrastructure/storage-blob"
  resource_group = azurerm_resource_group.rg_to_deploy_logfw.name
  deployment_name = local.deployment_name
  location = local.location
}

