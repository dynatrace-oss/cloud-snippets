# Azure Event Hub Deployment

Subscription-level ARM template with an Azure Portal UI definition for deploying Event Hub namespaces across multiple Azure locations. Designed for Dynatrace log and event ingestion with standardized configuration, CAF-compliant naming, and RBAC assignments for the Dynatrace monitoring service principal.

## Prerequisites

- An active Azure subscription with permissions to create resource groups and role assignments
- A registered Dynatrace monitoring service principal (Object ID required)
- `Microsoft.EventHub` and `Microsoft.Authorization` resource providers registered on the subscription

## Repository Structure

| File | Description |
|------|-------------|
| `armTemplate.jsonc` | ARM template (subscription-level) that deploys resource groups, Event Hub namespaces, Event Hubs, and RBAC role assignments |
| `createUiDefinition.json` | Azure Portal UI definition providing a guided wizard for configuring the deployment |

## What Gets Deployed

For each selected Azure location, the template creates:

1. **Resource Group** — `rg-dt-{dtTenantId}-{location}`
2. **Event Hub Namespace** — `evhns-dt-{dtTenantId}-{location}-{evhnsSuffix}` (suffix omitted when `evhnsSuffix` is empty) with auto-inflate (Standard SKU) and zone redundancy (if available)
3. **Event Hub for logs** — `dt-logs-evh` (configurable partition count, default: 4)
4. **Event Hub for events** — `dt-events-evh` (1 or 2 partitions, default: 1)
5. **RBAC Role Assignment** — [Azure Event Hubs Data Receiver](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/analytics#azure-event-hubs-data-receiver) role assigned to the Dynatrace service principal at resource group scope

All namespaces are tagged with `dt-log-ingest-activated: {dtConfigId}` and `managed-by: dynatrace` for autodiscovery.

## Portal Deployment

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdynatrace-oss%2Fcloud-snippets%2Fmain%2Fazure%2Fevent-hub-deployment%2FarmTemplate.jsonc/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fdynatrace-oss%2Fcloud-snippets%2Fmain%2Fazure%2Fevent-hub-deployment%2FcreateUiDefinition.json)

The UI definition guides you through three steps:

1. **Dynatrace Configuration** — Environment ID, Monitoring Configuration ID, and Service Principal selection
2. **Event Hubs Configuration** — Location selection and configuration size preset (or custom)
3. **Tags** — Optional custom tags per resource type

### Configuration Size Presets

| Preset | SKU | Baseline TU | Max TU (Auto-inflate) | Log Partitions | Event Partitions | Max Throughput |
|--------|-----|-------------|----------------------|----------------|-----------------|----------------|
| Dev/Test | Basic | 1 | — | 1 | 1 | 7.2 GB/hour |
| Small | Standard | 1 | 2 | 2 | 1 | 14.4 GB/hour |
| Medium | Standard | 1 | 4 | 4 | 1 | 57.6 GB/hour |
| Large | Standard | 1 | 16 | 16 | 2 | 115.2 GB/hour |
| Custom | Configurable | Configurable | Configurable | Configurable | Configurable | — |

## CLI Deployment

Since the template creates resource groups, it requires a **subscription-level deployment**:

```bash
# Default configuration
az deployment sub create \
  --location eastus \
  --template-file armTemplate.jsonc \
  --parameters dtTenantId=abc12345 \
               dtConfigId="cfc78e0e-a116-3289-bba1-ac6ad7e81c1f" \
               locations='["eastus","westeurope"]' \
               dtMonitoringServicePrincipalId="<service-principal-object-id>"

# Custom configuration
az deployment sub create \
  --location eastus \
  --template-file armTemplate.jsonc \
  --parameters dtTenantId=abc12345 \
               dtConfigId="cfc78e0e-a116-3289-bba1-ac6ad7e81c1f" \
               locations='["eastus","westus","westeurope"]' \
               dtMonitoringServicePrincipalId="<service-principal-object-id>" \
               skuName=Standard \
               skuCapacity=1 \
               maximumThroughputUnits=2 \
               evhLogsPartitionCount=2 \
               evhEventsPartitionCount=1 \
               tags='{"cost-center": "platform-team", "environment": "production"}'
```

> **Note:** The `dtMonitoringServicePrincipalId` parameter requires the service principal **Object ID** (not the App/Client ID). You can retrieve it with:
> ```bash
> az ad sp show --id <app-id> --query id -o tsv
> ```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `locations` | array | *(required)* | Azure locations for Event Hub namespace deployment |
| `dtTenantId` | string | *(required)* | Dynatrace tenant ID used in resource naming |
| `dtConfigId` | string | *(required)* | Monitoring configuration ID for tagging and autodiscovery |
| `dtMonitoringServicePrincipalId` | string | *(required)* | Service principal Object ID for RBAC assignment |
| `evhnsSuffix` | string | *(auto-generated)* | Optional suffix appended to the Event Hub Namespace name. If not specified, a random 4-character value is generated. Pass a fixed value to target an existing namespace on re-deployment. Pass `""` to omit the suffix entirely. |
| `skuName` | string | `Standard` | Namespace SKU: Basic, Standard, or Premium |
| `skuCapacity` | int | `1` | Baseline throughput units (1–20) |
| `maximumThroughputUnits` | int | `10` | Max throughput units for auto-inflate (1–40, Standard SKU only) |
| `evhLogsPartitionCount` | int | `4` | Partition count for `dt-logs-evh` (1–32) |
| `evhLogsRetentionInDays` | int | `1` | Message retention in days for `dt-logs-evh` (1–7) |
| `evhEventsPartitionCount` | int | `1` | Partition count for `dt-events-evh` (1 or 2) |
| `evhEventsRetentionInDays` | int | `1` | Message retention in days for `dt-events-evh` (1–7) |
| `tags` | object | `{}` | Additional custom tags (supports per-resource-type tags) |

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `deployedNamespaces` | array | Names of deployed Event Hub namespaces, e.g. `["evhns-dt-abc12345-eastus-a1b2", "evhns-dt-abc12345-westeurope-a1b2"]` |

## Naming Conventions

Following [Azure Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) naming conventions:

| Resource | Format | Example |
|----------|--------|---------|
| Resource Group | `rg-dt-{dtTenantId}-{location}` | `rg-dt-abc12345-eastus` |
| Event Hub Namespace | `evhns-dt-{dtTenantId}-{location}[-{evhnsSuffix}]` | `evhns-dt-abc12345-eastus-a1b2` |
| Event Hub (logs) | `dt-logs-evh` | `dt-logs-evh` |
| Event Hub (events) | `dt-events-evh` | `dt-events-evh` |
