resource "azurerm_storage_account" "this" {
  name                     = "${lower(replace(var.deployment_name, "/-?_? ?/", ""))}sa"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    ignore_changes = [
      tags["ACE:CREATED-BY"],
      tags["ACE:UPDATED-BY"],
      tags["dt_owner_email"]
    ]
  }
}