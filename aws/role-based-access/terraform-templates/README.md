# AWS Monitoring - Configuring AWS role-based access with Terraform

This folder contains two Terraform modules that allow you to configure AWS monitoring policy and role-based authentication. This will provide access to Amazon CloudWatch metrics from Dynatrace. The modules can be used with either a Dynatrace Saas deployment with Environment ActiveGate or a Dynatrace Managed Server. Additionally, it enables role-based access with either an Environment ActiveGate or a Dynatrace Managed Server.
See [AWS monitoring policy and role-based authentication](https://docs.dynatrace.com/docs/setup-and-configuration/setup-on-cloud-platforms/amazon-web-services/amazon-web-services-integrations/cloudwatch-metrics#aws-policy-and-authentication) for details.

>[!NOTE] 
The Terraform modules described are a translation of the CloudFormation scripts of this repository. [dynatrace_monitoring_role](./activegate_monitoring_role/) consilidates in a single Terraform module [role_based_access_monitored_account_template.yml](/aws/role-based-access/role_based_access_monitored_account_template.yml) and [role_based_access_no_AG_template.yml](/aws/role-based-access/role_based_access_no_AG_template.yml). And [activegate_monitoring_role](./activegate_monitoring_role/) maps directly with [role_based_access_AG_account_template.yml](/aws/role-based-access/role_based_access_AG_account_template.yml).


## Prerequisites

* Check this [link](https://docs.dynatrace.com/docs/setup-and-configuration/setup-on-cloud-platforms/amazon-web-services/amazon-web-services-integrations/cloudwatch-metrics#monitoring-prerequisites) for Monitoring prerequisites.
* Terraform. Check the official [Hashicorp page](https://developer.hashicorp.com/terraform/install) for installation details in your environment.
* Once you have Terraform installed, you will need to authenticate to AWS. For more details, see https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration. This page assumes you have already configured the authentication context with AWS, for instance, using aws cli.

## AWS role-based access configuration

There are two deployment models for Dynatrace ingesting data from Amazon CloudWatch:
* [Deployment with no ActiveGate](#deployment-with-no-activegate).
* [Deployment with existing ActiveGate](#deployment-with-existing-activegate).

### Deployment with no ActiveGate
Dynatrace SaaS needs role-based monitoring access to your AWS account. To configure role-based access, you can use the [dynatrace_monitoring_role](./activegate_monitoring_role/) module. For that

The deployment with no ActiveGate can be done by using the [dynatrace_monitoring_role](./activegate_monitoring_role/) module.

You need to specify the following arguments:

* `external_id`: External ID, copied from Settings > Cloud and virtualization > AWS in Dynatrace
* `role_name`: IAM role name that Dynatrace should use to get monitoring data. This must be the same name as the monitoring_role_name parameter used in the template for the account hosting the ActiveGate.
* `policy_name`: IAM policy name attached to the role

> [!NOTE]
> This module has two more arguments, `active_gate_account_id` and `active_gate_role_name`. You should **keep them as null**. If you set values you will be configuring [Role-based access for SaaS deployments with Environment ActiveGate](#Role-based-access-for-SaaS-deployments-with-Environment-ActiveGate)

You can prepare a `.tfvars` with your arguments. For instance:
```hcl
monitored_account_id = "999999999999"
assume_policy_name   = "sample_dynatrace_assume_policy"
monitoring_role_name = "sample_dynatrace_monitoring_role"
```

Then, execute the following Terraform commands:
```bash
terraform init
terraform apply -var-file="my_variables.tfvars"
```

### Deployment with existing ActiveGate
To configure a deployment with an existing ActiveGate, you should use two Terraform modules:

* [activegate_monitoring_role](./activegate_monitoring_role/) to [create a role for the ActiveGate on the account that hosts ActiveGate](#create-a-role-for-activegate-on-the-account-that-hosts-activegate).
* [dynatrace_monitoring_role](./dynatrace_monitoring_role/) for [Create a monitoring role for Dynatrace on your monitored account](#create-a-monitoring-role-for-dynatrace-on-your-monitored-account).

#### Create a role for ActiveGate on the account that hosts ActiveGate

You can use [activegate_monitoring_role](./activegate_monitoring_role/) specifying the following arguments:
* `active_gate_role_name`: IAM role name for the account hosting the ActiveGate for monitoring. This role name must be the same as the ActiveGate_role_name parameter used in the template for the monitored account.
* `assume_policy_name`:  IAM policy name attached to the role for the account hosting the ActiveGate
* `monitoring_role_name`: IAM role name that Dynatrace should use to get monitoring data. This role must be the same name as the RoleName parameter used in the template for the monitored account.
* `monitored_account_id`: ID of the account that Dynatrace should monitor

Now you can prepare a `.tfvars` file with the following arguments:

```hcl
active_gate_role_name = "dynatrace_ag_role_name"
assume_policy_name    = "dynatrace_assume_policy"
monitoring_role_name  = "dynatrace_monitoring_role"
monitored_account_id  = "999999999999"
```

Now, you can execute the following Terraform commands to apply the configuration:
```bash
terraform init
terraform apply -var-file="my_variables.tfvars"
```

#### Create a monitoring role for Dynatrace on your monitored account

To create the monitoring role, you can use [dynatrace_monitoring_role](./dynatrace_monitoring_role/) module. You need to specify the following arguments:

* `external_id`: External ID, copied from Settings > Cloud and virtualization > AWS in Dynatrace
* `role_name`: IAM role name that Dynatrace should use to get monitoring data. This must be the same name as the monitoring_role_name parameter used in the template for the account hosting the ActiveGate.
* `policy_name`: IAM policy name attached to the role
* `active_gate_account_id`: The ID of the account hosting the ActiveGate instance
* `active_gate_role_name`: IAM role name for the account hosting the ActiveGate for monitoring. This role name must be the same name as the ActiveGate_role_name parameter used in the template for the account hosting the ActiveGate.

Now you can prepare a `.tfvars` file with the following arguments:
```hcl
monitored_account_id   = "999999999999"
assume_policy_name     = "sample_dynatrace_assume_policy"
monitoring_role_name   = "sample_dynatrace_monitoring_role"
active_gate_account_id = "888888888888"
active_gate_role_name  = "sample_ag_dynatrace_monitoring_role"
```

Now, you can execute the following Terraform commands to apply the configuration:
```bash
terraform init
terraform apply -var-file="my_variables.tfvars"
```

### Set the region

By default, AWS will create the resources in your default region. If you want to specify the region you can configure the AWS provider. For that include the following in your Terraform template:
```hcl
terraform {
  required_version = ">=1.7"
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
```