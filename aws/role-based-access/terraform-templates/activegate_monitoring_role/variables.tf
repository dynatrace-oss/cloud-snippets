variable "active_gate_role_name" {
  description = "IAM role name for the account hosting the ActiveGate for monitoring. This must be the same name as the ActiveGate_role_name parameter used in the template for the monitored account."
  type        = string
  default     = "Dynatrace_ActiveGate_role"
}

variable "assume_policy_name" {
  description = "IAM policy name attached to the role for the account hosting the ActiveGate"
  type        = string
  default     = "Dynatrace_assume_policy"
}

variable "monitoring_role_name" {
  description = "IAM role name that Dynatrace should use to get monitoring data. This must be the same name as the RoleName parameter used in the template for the monitored account."
  type        = string
  default     = "Dynatrace_monitoring_role"
}

variable "monitored_account_id" {
  description = "ID of the account that Dynatrace should monitor"
  type        = string
}

