# Azure App Service With Dynatrace Integration Deployment

This repository contains resources for deploying web applications on Azure App Service with Dynatrace Integration at the same time.

## Contents

- [**ARM Template (linux-app-service.json)**](linux-app-service.json):  
  An Azure Resource Manager (ARM) template for deploying an Azure App Service.  
  It creates a Web App on Azure App Service and configures to enable Dynatrace OneAgent integration.

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

1. Create a parameters file and fill in the necessary parameters.  
   An example parameter file with all the parameters could look like this:

   ```json
    {
        "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {
          "webAppName": {
            "value": "exampleJavaWebApp"
          },
          "location": {
            "value": "East US"
          },
          "sku": {
            "value": "B1"
          },
          "linuxFxVersion": {
            "value": " JAVA|17-java17"
          },
          "appServicePlanName": {
              "value": "exampleAppServicePlan"
          },
          "DT_API_TOKEN": {
              "value": "your-api-token"
          },
          "DT_ENDPOINT": {
              "value": "https://{your-environment-id}.live.dynatrace.com"
          },
          "DT_INCLUDE": {
              "value": ["java", "apache"]
          },
          "START_APP_CMD": {
            "value": "java -jar /home/site/wwwroot/app.jar --server.port=8888"
          }
        }
      }

   ```

   However, the only required parameters are:
    - linuxFxVersion
    - DT_API_TOKEN
    - DT_ENDPOINT
    - DT_INCLUDE

    You should be especially careful with setting the ```START_APP_CMD``` value, if you just want to test DT installation it is recommended to not set this parameter which will cause the default command to be used.

2. Use the `linux-app-service.json` ARM template to deploy your Azure App Service.  
   Example command:  
   ```az deployment group create --resource-group linux-app-service --parameters linux-app-service.parameters.json --template-file linux-app-service.json```  

   You can take a look at the ARM template to better understand it.  

3. Perform the Zip Deploy.  
   Remember to use the same ```resource group``` and ```name``` as in the previously deployed App Service.  
   E.g.  
   ```az webapp deploy -g linux-app-service -n app-node-16 --src-path node.zip```

4. Restart your application once or twice.
