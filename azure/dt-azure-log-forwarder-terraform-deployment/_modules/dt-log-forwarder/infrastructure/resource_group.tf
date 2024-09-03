resource "azurerm_resource_group" "this" {
  name     = "rg-${var.deployment_name}"
  location = var.location
}
