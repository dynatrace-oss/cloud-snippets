resource "azurerm_resource_group" "this" {
  name     = "rg-${var.deployment_name}"
  location = var.location

  lifecycle {
    ignore_changes = [
      tags["ACE:CREATED-BY"],
      tags["ACE:UPDATED-BY"],
      tags["dt_owner_email"]
    ]
  }
}
