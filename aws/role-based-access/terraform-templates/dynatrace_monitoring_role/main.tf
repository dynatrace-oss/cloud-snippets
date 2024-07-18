data "aws_caller_identity" "current" {}

locals {
  principals_identifiers = var.active_gate_account_id == null || var.active_gate_role_name == null ? [
    "509560245411" # Dynatrace monitoring account ID
    ] : [
    "509560245411", # Dynatrace monitoring account ID
    "arn:aws:iam::${var.active_gate_account_id}:role/${var.active_gate_role_name}"
  ]
}

data "aws_iam_policy_document" "monitoring_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = local.principals_identifiers
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
    }
  }
}

resource "aws_iam_role" "monitoring_role" {
  name                = var.role_name
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.monitoring_role_policy_document.json
  managed_policy_arns = [aws_iam_policy.monitoring_policy.arn]
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

resource "aws_iam_policy" "monitoring_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.monitoring_policy_document.json
}


