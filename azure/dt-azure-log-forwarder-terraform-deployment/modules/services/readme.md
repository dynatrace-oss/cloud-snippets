# Azure Audit Log Forwarder

## Version Upgrade
To upgrade the version of the audit logforwarder several steps need to be taken:

### Step 1: Download the Specific Version
1. Download the desired version of the ZIP file containing the desired version of `dynatrace-azure-log-forwarder.zip` to deploy from [here](https://github.com/dynatrace-oss/dynatrace-azure-log-forwarder/releases)

### Step 2: Add the Code to the Directory
1. Change the name of the ZIP file to `dynatrace-azure-log-forwarder-<version_number>.zip`
2. Add ZIP file to `azure/_modules/dt-log-forwarder/services/src` directory.

### Update Terraform Configuration
1. Update the `version_number` in the Terraform configuration to match the newly deployed version.
