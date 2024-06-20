terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_iam_role" "ActiveGate_role" {
  name                = var.ActiveGate_role_name
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.ActiveGate_role_assume_role_policy_document.json
  managed_policy_arns = [aws_iam_policy.Dynatrace_assume_policy.arn]
}

data "aws_iam_policy_document" "ActiveGate_role_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "Dynatrace_assume_policy" {
  name   = var.assume_policy_name
  policy = data.aws_iam_policy_document.Dynatrace_assume_policy_document.json
}

data "aws_iam_policy_document" "Dynatrace_assume_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::${var.monitored_account_id}:role/${var.monitoring_role_name}"
    ]
  }
}

resource "aws_iam_instance_profile" "ActiveGate_instance_profile" {
  name = var.ActiveGate_role_name
  role = aws_iam_role.ActiveGate_role.name
}

data "aws_caller_identity" "current" {}

output "ActiveGate_role_name" {
  value       = aws_iam_role.ActiveGate_role.name
  description = "IAM role name for the account hosting the ActiveGate"
}

output "ActiveGate_account_id" {
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