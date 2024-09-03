# Module: dt-log-forwarder/services

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_key_vault.log_forwarder_kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.dynatrace_client_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_linux_function_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.kv_secrets_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_service_plan.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [random_string.random_kv_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_role_definition.kv_secrets_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/role_definition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | Name of the deployment | `string` | n/a | yes |
| <a name="input_dynatrace_url"></a> [dynatrace\_url](#input\_dynatrace\_url) | URL of DT Endpoint for Log Ingestion. | `string` | n/a | yes |
| <a name="input_event_hub_connection_string"></a> [event\_hub\_connection\_string](#input\_event\_hub\_connection\_string) | Connection string for the Azure Event Hubs instances that are configured to receive logs. | `string` | n/a | yes |
| <a name="input_event_hub_name"></a> [event\_hub\_name](#input\_event\_hub\_name) | Name of the Azure Event Hubs instances that are configured to receive logs. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region to deploy the infrastructure to. | `string` | n/a | yes |
| <a name="input_require_valid_certificate"></a> [require\_valid\_certificate](#input\_require\_valid\_certificate) | Should verify Dynatrace Logs Ingest endpoint SSL certificate? | `bool` | n/a | yes |
| <a name="input_version_number"></a> [version\_number](#input\_version\_number) | Release version of the dynatrace-azure-log-forwarder to deploy. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_endpoint"></a> [function\_endpoint](#output\_function\_endpoint) | Endpoint of function app |
| <a name="output_key_vault_identifier"></a> [key\_vault\_identifier](#output\_key\_vault\_identifier) | Identifier of the key vault |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | ID of the resource group |
