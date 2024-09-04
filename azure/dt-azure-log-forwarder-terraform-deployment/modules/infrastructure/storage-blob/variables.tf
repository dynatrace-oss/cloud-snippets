variable "resource_group" {
  type        = string
  description = "The resource group"
  default     = ""
}

variable "deployment_name" {
  description = "Name of the deployment"
  type     = string
  nullable = false
  validation {
    condition     = length(var.deployment_name) >= 3 && length(var.deployment_name) <= 20
    error_message = "Deployment name must not exceed 20 characters"
  }
}

variable "location" {
  description = "Region to deploy the infrastructure to."
  type     = string
  nullable = false
}