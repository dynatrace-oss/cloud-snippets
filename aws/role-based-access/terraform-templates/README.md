# Configuring AWS role based access with Terraform

This folder contains two Terraform modules that can be used to configure the role based access for Dynatrace Managed and SaaS deployments.

* dynatrace_monitoring_role: Role-based access for Managed and SaaS deployments with or without Environment ActiveGate
* activegate_monitoring_role: Role-based access for Managed and SaaS deployments with Environment ActiveGate

Both modules are a translation from CloudFormation templates available in this repository with a difference: `dynatrace_monitoring_role` module consolidates [role_based_access_monitored_account_template.yml](/aws/role-based-access/role_based_access_monitored_account_template.yml) and [role_based_access_no_AG_template.yml](/aws/role-based-access/role_based_access_no_AG_template.yml). Later in this README it's explained how to use the Terraform modules.

## How to use the Terraform templates

This section explains how to use the Terraform templates to cover the same scenarios than the CloudFormation scripts.

This page assumes you already have Terraform installed in your computer. If you need to install Terraform see the official page at https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli.

Once you have Terraform installed you will need to authenticate to AWS. For more details see https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration. This page assumes you have already configured the authentication context with AWS, for instance using aws cli.

### Role-based access for SaaS deployments without Environment ActiveGate

You can configure the Role-based access for SaaS by using [dynatrace_monitoring_role](./dynatrace_monitoring_role/) module. You need to specify the following arguments:

* `region`: The region where policy will be created
* `external_id`: External ID, copied from Settings > Cloud and virtualization > AWS in Dynatrace
* `role_name`: IAM role name that Dynatrace should use to get monitoring data. This must be the same name as the monitoring_role_name parameter used in the template for the account hosting the ActiveGate.
* `policy_name`: IAM policy name attached to the role

> [!NOTE]
> This module has two more arguments, `active_gate_account_id` and `active_gate_role_name`. You should **keep them as null**. If you set values you will be configuring [Role-based access for SaaS deployments with Environment ActiveGate](#Role-based-access-for-SaaS-deployments-with-Environment-ActiveGate)

You can prepare a `.tfvars` with your arguments. For instance:
```hcl
region               = "east-us-1"
monitored_account_id = "999999999999"
assume_policy_name   = "sample_dynatrace_assume_policy"
monitoring_role_name = "sample_dynatrace_monitoring_role"
```

Now, you can execute the following Terraform commands:
```bash
terraform init
terraform apply -var-file="my_variables.tfvars"
```

### Role-based access for SaaS deployments with Environment ActiveGate

You can use [dynatrace_monitoring_role](./dynatrace_monitoring_role/) module as well. This time adding two additional arguments:

* `active_gate_account_id`: The ID of the account hosting the ActiveGate instance
* `active_gate_role_name`: IAM role name for the account hosting the ActiveGate for monitoring. This must be the same name as the ActiveGate_role_name parameter used in the template for the account hosting the ActiveGate.

Now you can prepare a `.tfvars` file with the following arguments:
```hcl
region                 = "east-us-1"
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

### Role-based access for Managed and SaaS deployments with Environment ActiveGate

You can use [activegate_monitoring_role](./activegate_monitoring_role/) module. You need to specify the following arguments:
* `region`: The region where policy will be created
* `active_gate_role_name`: IAM role name for the account hosting the ActiveGate for monitoring. This must be the same name as the ActiveGate_role_name parameter used in the template for the monitored account.
* `assume_policy_name`:  IAM policy name attached to the role for the account hosting the ActiveGate
* `monitoring_role_name`: IAM role name that Dynatrace should use to get monitoring data. This must be the same name as the RoleName parameter used in the template for the monitored account.
* `monitored_account_id`: ID of the account that Dynatrace should monitor

Now you can prepare a `.tfvars` file with the following arguments:

```hcl
region                = "east-us-1"
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