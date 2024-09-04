variable "location" {
  description = "Region to deploy the infrastructure to."
  type        = string
  nullable    = false
}

variable "deployment_name" {
  description = "Name of the deployment"
  type        = string
  nullable    = false
  validation {
    condition     = length(var.deployment_name) >= 3 && length(var.deployment_name) <= 20
    error_message = "Deployment name must not exceed 20 characters"
  }
}

variable "event_hub_connection_string" {
  description = "Connection string for the Azure Event Hubs instances that are configured to receive logs."
  type        = string
  nullable    = false
}

variable "event_hub_name" {
  description = "Name of the Azure Event Hubs instances that are configured to receive logs."
  type        = string
  nullable    = false
}

variable "dynatrace_url" {
  description = "URL of DT Endpoint for Log Ingestion."
  type        = string
  nullable    = false
}

variable "dynatrace_access_key" {
  description = "Dynatrace token"
  type        = string
  nullable    = false
}

variable "version_number" {
  description = "Release version of the dynatrace-azure-log-forwarder to deploy."
  type        = string
  nullable    = false
}

variable "require_valid_certificate" {
  description = "Should verify Dynatrace Logs Ingest endpoint SSL certificate?"
  type        = bool
  nullable    = false
}

variable "resource_group" {
  type        = string
  description = "The resource group"
  default     = ""
}

variable "storage_account_name" {
  type        = string
  description = "The name of the Azure Storage account"
}

variable "storage_account_access_key" {
  type        = string
  description = "The access key of the Azure Storage account"
}
