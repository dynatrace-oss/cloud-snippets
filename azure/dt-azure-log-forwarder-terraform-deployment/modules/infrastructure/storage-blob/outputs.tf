output "azurerm_storage_account_name" {
  value       = azurerm_storage_account.storage-blob.name
  description = "The Azure Blob storage account name."
}

output "azurerm_storage_account_key" {
  value       = azurerm_storage_account.storage-blob.primary_access_key
  sensitive   = true
  description = "The Azure Blob storage access key."
}
