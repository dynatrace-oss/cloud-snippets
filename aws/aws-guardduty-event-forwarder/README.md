# AWS GuardDuty Event Forwarder

This folder contains an [AWS Cloud Formation](https://aws.amazon.com/cloudformation/) template, which sets up necessary resources in AWS to forward AWS GuardDuty [security findings](https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html) to the Dynatrace OpenPipeline security event ingest endpoint.

More details can be found in the official documentation:

- [Security events ingest](https://dt-url.net/1d63p0v)
- [Ingest AWS GuardDuty security findings](https://dt-url.net/jv03zhm)

Follow these steps to create the AWS GuardDuty Event Forwarder with Infrastructure as Code (IaC):

### 0. Prerequisites

- Dynatrace version

  | Feature                | Version |
  | ---------------------- | ------- |
  | security findings      | 1.310+  |

- Make sure to install and configure the [latest AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- In a terminal, enter `aws configure` and set `us-east-1` (or your preferred region) as the default region for setting up all resources.

### 1. Set up secret with OpenPipeline Api-Token

Replace the `Api-Token` in the following command with a valid [access token](https://docs.dynatrace.com/docs/manage/access-control/access-tokens) that has the `openpipeline.events_security` token scope:

```bash
aws secretsmanager create-secret \
--name dynatrace-aws-guardduty-event-forwarder-open-pipeline-ingest-api-token \
--description "Dynatrace token, allows data to be sent to the OpenPipeline endpoint." \
--secret-string '{"DYNATRACE_OPENPIPELINE_INGEST_API_TOKEN": "<your_API_token>
```

### 2. Create the resources in AWS with the CloudFormation template

The following command executes the CloudFormation template and creates the necessary resources. 

Run the command, making sure to replace

- `<AWS_secret_ARN>` with the ARN of the secret created previously
  
- `<your_Dynatrace_ingest_URL>` with the URL of your Dynatrace ingest endpoint for security events (for example, `https://mytenant.apps.dynatrace.com/platform/ingest/v1/events.security`)

```bash
aws cloudformation deploy  \
--template-file ./aws/aws-guardduty-event-forwarder/dynatrace_aws_guardduty_event_forwarder_template.yaml \
--stack-name dynatrace-aws-guardduty-event-forwarder \
--parameter-overrides \
"AwsSecretArn"="<AWS_secret_ARN>" \
"DynatraceOpenPipelineEndpoint"="<your_Dynatrace_ingest_URL>" \
--capabilities CAPABILITY_NAMED_IAM
```

#### Additional parameters that can be customized:

- `AwsSecretKeyName`: Name of the secret key, defaults to `DYNATRACE_OPENPIPELINE_INGEST_API_TOKEN`


### Tip: (Optional) Delete stack

If they're not needed anymore, you can delete the resources created from AWS with the following command:

```bash
aws cloudformation delete-stack --stack-name dynatrace-aws-guardduty-event-forwarder
```
