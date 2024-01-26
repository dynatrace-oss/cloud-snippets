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

resource "aws_iam_role" "monitoring_role" {
  name                = var.role_name
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.monitoring_role_policy_document.json
  managed_policy_arns = [aws_iam_policy.monitoring_policy.arn]
}

data "aws_iam_policy_document" "monitoring_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.ActiveGate_account_id}:role/${var.ActiveGate_role_name}",
        "509560245411" # Dynatrace monitoring account ID
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
    }
  }
}

resource "aws_iam_policy" "monitoring_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.monitoring_policy_document.json
}

data "aws_iam_policy_document" "monitoring_policy_document" {
  statement {
    sid = "VisualEditor0"
    actions = [
      "acm-pca:ListCertificateAuthorities",
      "apigateway:GET",
      "apprunner:ListServices",
      "appstream:DescribeFleets",
      "appsync:ListGraphqlApis",
      "athena:ListWorkGroups",
      "autoscaling:DescribeAutoScalingGroups",
      "cloudformation:ListStackResources",
      "cloudfront:ListDistributions",
      "cloudhsm:DescribeClusters",
      "cloudsearch:DescribeDomains",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "codebuild:ListProjects",
      "datasync:ListTasks",
      "dax:DescribeClusters",
      "directconnect:DescribeConnections",
      "dms:DescribeReplicationInstances",
      "dynamodb:ListTables",
      "dynamodb:ListTagsOfResource",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeNatGateways",
      "ec2:DescribeSpotFleetRequests",
      "ec2:DescribeTransitGateways",
      "ec2:DescribeVolumes",
      "ec2:DescribeVpnConnections",
      "ecs:ListClusters",
      "eks:ListClusters",
      "elasticache:DescribeCacheClusters",
      "elasticbeanstalk:DescribeEnvironmentResources",
      "elasticbeanstalk:DescribeEnvironments",
      "elasticfilesystem:DescribeFileSystems",
      "elasticloadbalancing:DescribeInstanceHealth",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticmapreduce:ListClusters",
      "elastictranscoder:ListPipelines",
      "es:ListDomainNames",
      "events:ListEventBuses",
      "firehose:ListDeliveryStreams",
      "fsx:DescribeFileSystems",
      "gamelift:ListFleets",
      "glue:GetJobs",
      "inspector:ListAssessmentTemplates",
      "kafka:ListClusters",
      "kinesis:ListStreams",
      "kinesisanalytics:ListApplications",
      "kinesisvideo:ListStreams",
      "lambda:ListFunctions",
      "lambda:ListTags",
      "lex:GetBots",
      "logs:DescribeLogGroups",
      "mediaconnect:ListFlows",
      "mediaconvert:DescribeEndpoints",
      "mediapackage-vod:ListPackagingConfigurations",
      "mediapackage:ListChannels",
      "mediatailor:ListPlaybackConfigurations",
      "opsworks:DescribeStacks",
      "qldb:ListLedgers",
      "rds:DescribeDBClusters",
      "rds:DescribeDBInstances",
      "rds:DescribeEvents",
      "rds:ListTagsForResource",
      "redshift:DescribeClusters",
      "robomaker:ListSimulationJobs",
      "route53:ListHostedZones",
      "route53resolver:ListResolverEndpoints",
      "s3:ListAllMyBuckets",
      "sagemaker:ListEndpoints",
      "sns:ListTopics",
      "sqs:ListQueues",
      "storagegateway:ListGateways",
      "sts:GetCallerIdentity",
      "swf:ListDomains",
      "tag:GetResources",
      "tag:GetTagKeys",
      "transfer:ListServers",
      "workmail:ListOrganizations",
      "workspaces:DescribeWorkspaces",
    ]
    resources = ["*"]
  }
}

data "aws_caller_identity" "current" {}

output "role_name" {
  value       = aws_iam_role.monitoring_role.name
  description = "IAM role that Dynatrace should use to get monitoring data"
}

output "account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "Your Amazon account ID"
}