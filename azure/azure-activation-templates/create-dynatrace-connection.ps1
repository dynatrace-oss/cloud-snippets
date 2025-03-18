$requiredEnvVars = @(
    'dynatraceApiKey', 
    'dynatraceTenant',
    'dynatraceConfigurationId', 
    'directoryId', 
    'clientId', 
    'clientSecret', 
    'subscriptionId')

foreach ($var in $requiredEnvVars) {
    if (-not (Test-Path "Env:$var")) {
        throw "Environment variable $var is not set."
    }
}

$activationData = @{}

$environment = "$($Env:dynatraceEnvironment ?? 'live')"
$has_endpoint = "https://$Env:dynatraceTenant.$environment.dynatracelabs.com/api/v2/settings/objects?validateOnly=false&adminAccess=false"

$jsonBody = @"
[
    {
        "value": {
            "azureClientSecret": {
                "directoryId": "$($Env:directoryId)",
                "applicationId": "$($Env:clientId)",
                "clientSecret": "$($Env:clientSecret)",
                "consumers": ["DA"]
            },
            "name": "Dynatrace Azure Monitoring ($($Env:subscriptionId))",
            "type": "clientSecret"
        },
        "schemaVersion": "0.0.1",
        "schemaId": "builtin:hyperscaler-authentication.connections.azure"
    }
]
"@

try
{
    Write-Output "Req: POST $has_endpoint"
    $response = Invoke-WebRequest -SkipCertificateCheck `
        -ContentType "application/json" `
        -Method POST `
        -Uri $has_endpoint `
        -Headers @{
            "Accept" = "application/json"
            "Authorization" = "Api-Token $Env:dynatraceApiKey"
        } `
        -Body ($jsonBody)

    if ($response.StatusCode -eq 200) {
        $jsonResponse = $response.Content | ConvertFrom-Json
        
        $activationData['connectionId'] = $jsonResponse[0].objectId
        Write-Output $activationData['connectionId']
    } else {
        throw "Request failed with status code: $($response)"
    }
}
catch {
    throw "Request failed with status code: $($_.ErrorDetails.Message)"
}

$extensionName = "custom:my.awesome.azure.extension"
$efx_endpoint = "https://$Env:dynatraceTenant.$environment.dynatracelabs.com/api/v2/extensions/$extensionName/monitoringConfigurations"

$configurationObject = $null

try
{
    Write-Output "Req: GET $efx_endpoint"
    $response = Invoke-WebRequest -SkipCertificateCheck `
        -ContentType "application/json" `
        -Method GET `
        -Uri "$efx_endpoint/$env:dynatraceConfigurationId" `
        -Headers @{
            "Accept" = "application/json"
            "Authorization" = "Api-Token $Env:dynatraceApiKey"
        } `
        -Body ($jsonBody)

    if ($response.StatusCode -eq 200) {
        $configurationObject = $response.Content | ConvertFrom-Json
        $configurationObject.value.azure.credentials[0].connectionId = $activationData['connectionId']
        $activationData['updatedMonitoringConfigurationJson'] = $configurationObject | ConvertTo-Json -Depth 100
    } else {
        throw "Request failed with status code: $($response)"
    }
}
catch {
    throw "Request failed with status code: $($_.ErrorDetails.Message)"
}

try
{
    Write-Output "Req: PUT $efx_endpoint"
    $response = Invoke-WebRequest -SkipCertificateCheck `
        -ContentType "application/json" `
        -Method PUT `
        -Uri "$efx_endpoint/$env:dynatraceConfigurationId" `
        -Headers @{
            "Accept" = "application/json"
            "Authorization" = "Api-Token $Env:dynatraceApiKey"
        } `
        -Body ($activationData['updatedMonitoringConfigurationJson'])
}
catch {
    throw "Request failed with status code: $($_.ErrorDetails.Message)"
}