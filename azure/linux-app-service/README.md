# Azure App Service With Dynatrace Integration Deployment

This repository contains resources for deploying web applications on Azure App Service with Dynatrace Integration at the same time.

## Contents

- [**ARM Template (linux-app-service.json)**](linux-app-service.json):  
  An Azure Resource Manager (ARM) template for deploying an Azure App Service.  
  It creates a Web App on Azure App Service and configures to enable Dynatrace Oneagent integration.

- [**Dynatrace OneAgent Installer Script (oneagent-installer.sh)**](oneagent-installer.sh):  
  A wrapper script for installing and starting the Dynatrace OneAgent on Azure App Service.  
  It uses the ```DT_INCLUDE```, ```DT_API_TOKEN```, ```DT_ENDPOINT``` environments variables and detects ```DT_FLAVOR``` to download the actual Dynatrace Oneagent installer.  
  Then the ```START_APP_CMD``` variable is used with the ```LD_PRELOAD``` variable to start the main application process.  
  All the environment variables are preconfigured using the ARM template.  

- [**Runtime Samples**](runtimes-samples):  
  This directory contains two subdirectories:  
  - **zip-deploy-samples**: Pre-packaged ZIP files for deploying sample applications to Azure App Service for using Zip Deploy utility
  - **source-code**: Source code for the zipped samples for better readability and easier modification of the code

## Usage

1. Use the `linux-app-service.json` ARM template to deploy your Azure App Service.  
   Create a parameters file and fill in the necessary parameters, you also should take a look at the ARM template to better understand it.  
   Example command:  
   ```az deployment group create --resource-group linux-app-service --parameters linux-app-service.parameters.json --template-file linux-app-service.json```

2. Perform the Zip Deploy.  
   Remember to use the same ```resource group``` and ```name``` as in previously deployed App Service.  
   Eg.:  
    ```az webapp deploy -g linux-app-service -n app-node-16 --src-path node.zip```

3. Restart your application once or twice.
