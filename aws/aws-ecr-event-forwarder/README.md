# AWS Event Forwarder Lambda - Basic scanning

This folder contains an [AWS Cloud Formation](https://aws.amazon.com/cloudformation/) template, which sets up necessary resources in AWS to forward AWS Elastic Container Registry (ECR) container vulnerability findings and scan events for [basic scanning](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning-basic.html) to the Dynatrace OpenPipeline security event ingest endpoint.

More details can be found in the official documentation:

- [Security events ingest](https://dt-url.net/1d63p0v)
- [Ingest AWS ECR vulnerability findings](https://dt-url.net/tz03pa8)

Follow these steps to create the AWS ECR Event Forwarder with Infrastructure as Code (IaC):

### 0. Prerequisites

- Dynatrace version

  | Feature                | Version |
  | ---------------------- | ------- |
  | vulnerability findings | 1.296+  |
  | scan events            | 1.301+  |

- Make sure to install and configure the [latest AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- In a terminal, enter `aws configure` and set `us-east-1` (or your preferred region) as the default region for setting up all resources.

### 1. Set up secret with OpenPipeline Api-Token

Replace the `Api-Token` in the following command with a valid [access token](https://docs.dynatrace.com/docs/manage/access-control/access-tokens) that has the `openpipeline.events_security` token scope:

```bash
aws secretsmanager create-secret \
--name dynatrace-aws-ecr-event-forwarder-open-pipeline-ingest-api-token \
--description "Dynatrace Token, which allows to send data to the Open Pipeline endpoint." \
--secret-string '{"DYNATRACE_OPENPIPELINE_INGEST_API_TOKEN": "Api-Token"}'
```

### 2. Create the resources in AWS with the CloudFormation template

The following command executes the CloudFormation template and creates the necessary resources. Replace the `AwsSecretArn` variable in the following command with the actual ARN of the secret that was created in the previous step:

```bash
aws cloudformation deploy  \
--template-file ./dynatrace_aws_event_forwarder_template.yaml \
--stack-name dynatrace-aws-ecr-event-forwarder \
--parameter-overrides \
"AwsSecretArn"="arn:aws:secretsmanager:us-east-1:12345678:secret:dynatrace-aws-ecr-event-forwarder-open-pipeline-ingest-api-token-testxyz" \
"DynatraceDomain"="{your-environment-id}.live.dynatrace.com" \
--capabilities CAPABILITY_NAMED_IAM
```

#### Additional parameters that can be customized:

- `AwsSecretKeyName`: Name of the secret key, defaults to `DYNATRACE_OPENPIPELINE_INGEST_API_TOKEN`

- `DynatraceOpenPipelineEndpointPath`: Path of the OpenPipeline security endpoint, defaults to `/platform/ingest/v1/events.security?type=container_finding&provider_product=aws_ecr`

### Tip: (Optional) Delete stack

If they're not needed anymore, you can delete the resources created from AWS with the following command:

```bash
aws cloudformation delete-stack --stack-name dynatrace-aws-ecr-event-forwarder
```
