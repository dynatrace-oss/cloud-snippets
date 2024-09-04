output "function_endpoint" {
  description = "Endpoint of function app"
  value = azurerm_linux_function_app.application.id
}