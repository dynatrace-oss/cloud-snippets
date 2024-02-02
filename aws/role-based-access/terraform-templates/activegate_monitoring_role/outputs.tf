output "active_gate_role_name" {
  value       = aws_iam_role.active_gate_role.name
  description = "IAM role name for the account hosting the ActiveGate"
}

output "active_gate_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "Your Amazon account ID hosting the ActiveGate"
}

output "monitoring_role_name" {
  value       = var.monitoring_role_name
  description = "IAM role that Dynatrace should use to get monitoring data"
}

output "monitored_account_id" {
  value       = var.monitored_account_id
  description = "ID of the account that Dynatrace should monitor"
}
