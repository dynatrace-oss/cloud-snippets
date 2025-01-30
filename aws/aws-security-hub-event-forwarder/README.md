# AWS Security Hub event forwarder

This folder contains an [AWS Cloud Formation](https://aws.amazon.com/cloudformation/) template, which sets up the necessary resources in AWS to forward AWS Security Hub to the Dynatrace OpenPipeline security event ingest endpoint.

More details can be found in the official documentation:

- [Security events ingest](https://dt-url.net/1d63p0v)
- [Ingest AWS Security Hub findings](https://dt-url.net/bl23u9i)

Follow the steps below to create the AWS Security Hub event forwarder with Infrastructure as Code (IaC):

## 0. Prerequisites

- Dynatrace version

  | Feature                | Version |
  |------------------------| ------- |
  | vulnerability findings | 1.306+  |
  | compliance findings    | 1.308+  |
  | detection findings     | 1.308+  |

- Make sure to install and configure the [latest AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
- In a terminal, enter `aws configure` and set `us-east-1` (or your preferred region) as the default region.
- Make sure that any previous deployments of the Dynatrace AWS Security Hub event forwarder template are deleted by running:

  ```bash
  aws cloudformation delete-stack --stack-name dynatrace-aws-security-hub-event-forwarder
  ```

## 1. Set up the secret with the OpenPipeline Api-Token

Run the following command, making sure to replace the Api-Token with a valid [access token](https://docs.dynatrace.com/docs/manage/access-control/access-tokens) that has the `openpipeline.events_security` token scope.

```bash
aws secretsmanager create-secret \
--name dynatrace-aws-security-hub-event-forwarder-open-pipeline-ingest-api-token \
--description "Dynatrace Token, which allows to send data to the Open Pipeline endpoint." \
--secret-string '{"DYNATRACE_OPENPIPELINE_INGEST_API_TOKEN": "<Token>"}'
```

## 2. Create the resources in AWS with the CloudFormation template

Run the following command to execute the CloudFormation template and create the necessary resources.
Make sure to replace the `AwsSecretArn` variable in the following command with the actual ARN of the secret that was created in the previous step.

```bash
aws cloudformation deploy  \
--template-file ./dynatrace_aws_security_hub_event_forwarder_template.yaml \
--stack-name dynatrace-aws-security-hub-event-forwarder \
--parameter-overrides \
"AwsSecretArn"="arn:aws:secretsmanager:us-east-1:12345678:secret:dynatrace-aws-security-hub-event-forwarder-open-pipeline-ingest-api-token-testxyz" \
"DynatraceDomain"="https://{your-environment-id}.live.dynatrace.com" \
--capabilities CAPABILITY_NAMED_IAM
```

### Additional parameters that can be customized

- `AwsSecretKeyName`: Name of the secret key, defaults to `DYNATRACE_OPENPIPELINE_INGEST_API_TOKEN`

- `DynatraceOpenPipelineEndpointPath`: Path to the OpenPipeline security endpoint, defaults to `/platform/ingest/v1/events.security`

## (Optional) Delete stack

If they're not needed anymore, you can delete the resources created from AWS with the following command:

```bash
aws cloudformation delete-stack --stack-name dynatrace-aws-security-hub-event-forwarder
```
