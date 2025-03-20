param location string = resourceGroup().location
param dt_api_url string
param dt_token string

var uniqueStr = uniqueString(resourceGroup().id)
var eventHubSku = 'Basic'
var eventHubName = 'dt-appsec-event-hub'
var eventHubNamespaceName = 'dt-appsec-event-hub-ns-${uniqueStr}'
var functionAppName = 'dt-appsec-function-app-${uniqueStr}'
var hostingPlanName = 'dt-appsec-hosting-plan'
var storageAccountType = 'Standard_LRS'
var storageAccountName = 'azfunctions${uniqueStr}'


resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: eventHubSku
    tier: eventHubSku
    capacity: 2
  }
  properties: {
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
    minimumTlsVersion: '1.2'
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  name: eventHubName
  properties: {
    messageRetentionInDays: 1
    partitionCount: 1
  }
}

resource triggerPolicy 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2024-01-01' = {
  parent: eventHub
  name: 'listen_policy'
  properties: {
    rights: [
      'Listen'
    ]
  }
}
var triggerPolicyConnection = triggerPolicy.listKeys().primaryConnectionString

resource defenderPolicy 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2024-01-01' = {
  parent: eventHub
  name: 'defender_policy'
  properties: {
    rights: [
      'Manage'
      'Listen'
      'Send'
    ]
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
    minimumTlsVersion: 'TLS1_2'
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${functionAppName}-workspace'
  location: location
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${functionAppName}-app-insights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: hostingPlan.id
    reserved: true
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${applicationInsights.properties.InstrumentationKey}'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'DT_API_URL'
          value: dt_api_url
        }
        {
          name: 'DT_TOKEN'
          value: dt_token
        }
        {
          name: 'EventHubConnectionString'
          value: triggerPolicyConnection
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT' // required for remote build, see https://docs.microsoft.com/en-us/azure/azure-functions/functions-deployment-technologies#remote-build-on-linux
          value: 'true'
        }
        {
          name: 'ENABLE_ORYX_BUILD' // required for remote build on Linux specifically, see https://docs.microsoft.com/en-us/azure/azure-functions/functions-deployment-technologies#remote-build-on-linux
          value: 'true'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: 'https://github.com/NoahGirard/cloud-snippets/raw/refs/heads/main/azure/msdc-security-event-forwarder/msdc_function_app.zip'
        }
      ]
      numberOfWorkers: 1
      linuxFxVersion: 'Python|3.11'
      minimumElasticInstanceCount: 0
      pythonVersion: '3.11'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}
