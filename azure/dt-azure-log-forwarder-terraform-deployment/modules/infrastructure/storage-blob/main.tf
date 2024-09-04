resource "azurerm_storage_account" "storage-blob" {
  name                     = "${lower(replace(var.deployment_name, "/-?_? ?/", ""))}sa"
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}