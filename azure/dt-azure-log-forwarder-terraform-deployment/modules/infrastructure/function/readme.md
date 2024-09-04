# Module: dt-log-forwarder/infrastructure/function

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_function_app.application](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_service_plan.service_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | Name of the deployment | `string` | n/a | yes |
| <a name="input_dynatrace_access_key"></a> [dynatrace\_access\_key](#input\_dynatrace\_access\_key) | Dynatrace token | `string` | n/a | yes |
| <a name="input_dynatrace_url"></a> [dynatrace\_url](#input\_dynatrace\_url) | URL of DT Endpoint for Log Ingestion. | `string` | n/a | yes |
| <a name="input_event_hub_connection_string"></a> [event\_hub\_connection\_string](#input\_event\_hub\_connection\_string) | Connection string for the Azure Event Hubs instances that are configured to receive logs. | `string` | n/a | yes |
| <a name="input_event_hub_name"></a> [event\_hub\_name](#input\_event\_hub\_name) | Name of the Azure Event Hubs instances that are configured to receive logs. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region to deploy the infrastructure to. | `string` | n/a | yes |
| <a name="input_require_valid_certificate"></a> [require\_valid\_certificate](#input\_require\_valid\_certificate) | Should verify Dynatrace Logs Ingest endpoint SSL certificate? | `bool` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The resource group | `string` | `""` | no |
| <a name="input_storage_account_access_key"></a> [storage\_account\_access\_key](#input\_storage\_account\_access\_key) | The access key of the Azure Storage account | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the Azure Storage account | `string` | n/a | yes |
| <a name="input_version_number"></a> [version\_number](#input\_version\_number) | Release version of the dynatrace-azure-log-forwarder to deploy. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_endpoint"></a> [function\_endpoint](#output\_function\_endpoint) | Endpoint of function app |
