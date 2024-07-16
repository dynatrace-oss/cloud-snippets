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

variable "active_gate_account_id" {
  description = "The ID of the account hosting the ActiveGate instance"
  type        = string
  nullable    = true
  default     = null
}

variable "active_gate_role_name" {
  description = "IAM role name for the account hosting the ActiveGate for monitoring. This must be the same name as the ActiveGate_role_name parameter used in the template for the account hosting the ActiveGate."
  type        = string
  nullable    = true
  default     = null
}
