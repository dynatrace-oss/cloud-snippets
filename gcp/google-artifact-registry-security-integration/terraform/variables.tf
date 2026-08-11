variable "project_id" {
  description = "GCP project ID where the resources will be deployed."
  type        = string
}

variable "region" {
  description = "GCP region for the Cloud Run function."
  type        = string
  default     = "europe-west1"
}

variable "gcp_org_id" {
  description = "GCP organization ID for enrichment."
  type        = string
}

variable "gcp_org_name" {
  description = "GCP organization name for enrichment."
  type        = string
}

variable "dt_base_url" {
  description = "Dynatrace environment URL (e.g. https://abc12345.live.dynatrace.com)."
  type        = string
}

variable "dt_api_token_secret_id" {
  description = "Secret ID for Google Secret Manager secret containing the Dynatrace API token (e.g. dt-mytenant-openpipeline-token)."
  type        = string
  sensitive   = true
}

variable "function_name" {
  description = "Name of the Cloud Run function."
  type        = string
  default     = "dt-artifact-analysis"
}

variable "min_instances" {
  description = "Minimum number of Cloud Run instances."
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of Cloud Run instances."
  type        = number
  default     = 10
}

variable "concurrency" {
  description = "Maximum concurrent requests per instance."
  type        = number
  default     = 100
}

variable "function_source_url" {
  description = "URL to download the function source zip from GitHub."
  type        = string
  default     = "https://github.com/dynatrace-oss/cloud-snippets/raw/refs/heads/main/gcp/google-artifact-registry-security-integration/cloud_run_function.zip"
}
