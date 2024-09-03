output "resource_group_id" {
  description = "ID of the resource group"
  value = azurerm_resource_group.this.id
}

output "function_endpoint" {
  description = "Endpoint of function app"
  value = azurerm_linux_function_app.this.id
}