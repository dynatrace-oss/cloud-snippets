# Module: dt-log-forwarder/infrastructure/storage_blob

## Requirements

No requirements.

## Providers

| Name                                                          | Version |
| ------------------------------------------------------------- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                    | Type     |
| --------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [azurerm_storage_account.storage_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |

## Inputs

| Name                                                                              | Description                             | Type     | Default | Required |
| --------------------------------------------------------------------------------- | --------------------------------------- | -------- | ------- | :------: |
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | Name of the deployment                  | `string` | n/a     |   yes    |
| <a name="input_location"></a> [location](#input\_location)                        | Region to deploy the infrastructure to. | `string` | n/a     |   yes    |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group)    | The resource group                      | `string` | `""`    |    no    |

## Outputs

| Name                                                                                                                           | Description                          |
| ------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------ |
| <a name="output_azurerm_storage_account_key"></a> [azurerm\_storage\_account\_key](#output\_azurerm\_storage\_account\_key)    | The Azure Blob storage access key.   |
| <a name="output_azurerm_storage_account_name"></a> [azurerm\_storage\_account\_name](#output\_azurerm\_storage\_account\_name) | The Azure Blob storage account name. |
