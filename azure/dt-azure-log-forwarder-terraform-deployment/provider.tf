provider "azurerm" {
  subscription_id = "69b51384-146c-4685-9dab-5ae01877d7b8"
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}
