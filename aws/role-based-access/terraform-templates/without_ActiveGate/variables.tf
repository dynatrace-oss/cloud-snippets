variable "region" {
  description = "The region where policy will be created"
  type        = string
  default     = "us-east-1"
}

variable "external_id" {
  description = "External ID, copied from Settings > Cloud and virtualization > AWS in Dynatrace"
  type        = string
}

variable "role_name" {
  description = "IAM role name that Dynatrace should use to get monitoring data. This must be the same name as the monitoring_role_name parameter used in the template for the account hosting the ActiveGate."
  type        = string
  default     = "Dynatrace_monitoring_role"
}

variable "policy_name" {
  description = "IAM policy name attached to the role"
  type        = string
  default     = "Dynatrace_monitoring_policy"
}

