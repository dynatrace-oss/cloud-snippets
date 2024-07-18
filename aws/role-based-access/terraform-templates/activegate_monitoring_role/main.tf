data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "active_gate_role_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "active_gate_role" {
  name                = var.active_gate_role_name
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.active_gate_role_assume_role_policy_document.json
  managed_policy_arns = [aws_iam_policy.dynatrace_assume_policy.arn]
}

data "aws_iam_policy_document" "dynatrace_assume_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::${var.monitored_account_id}:role/${var.monitoring_role_name}"
    ]
  }
}

resource "aws_iam_policy" "dynatrace_assume_policy" {
  name   = var.assume_policy_name
  policy = data.aws_iam_policy_document.dynatrace_assume_policy_document.json
}



resource "aws_iam_instance_profile" "active_gate_instance_profile" {
  name = var.active_gate_role_name
  role = aws_iam_role.active_gate_role.name
}



