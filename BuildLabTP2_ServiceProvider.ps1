#MUST be run from HOST Server
#Requires -RunAsAdministrator
$ISOPath = 'C:\Users\AzureStackAdmin\Downloads\14393.0.161119-1705.RS1_REFRESH_SERVER_EVAL_X64FRE_EN-US.ISO' #Provide path to ISO YOU downloaded
$AADTenantDomain = 'YOURDOMAIN.ONMICROSOFT.COM'
$ServiceAdminUsername = 'SERVICE ADMIN ACCOUNT'
$ServiceAdminPassword = 'SERVICE ADMIN PASSWORD!'
$AzureAD = "YOURBILLINGDOMAIN.ONMICROSOFT.COM"
$AzureSubID = "YOURBILLLINGDOMAIN GUID"
$UserAccountName = "YOURBILLLING DOMAIN OWNER"
$MASDomain ='local.azurestack.external'
$AdminUri = 'https://api.{0}' -f $MASDomain
$ArmLocation='local'
$OfferRG='OffersandPlans'
$DelegatedOffersRG='CASDelegatedOffers'

#region Quota Functions

function New-StorageQuota
{
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $quotaName,
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [ValidatePattern('[0-9]+')]
        [string] $capacityInGb = 100,
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [ValidatePattern('[0-9]+')]
        [string] $numberOfStorageAccounts = 20
    )    

    $ApiVersion = "2015-12-01-preview"

    $uri = "{0}/subscriptions/{1}/providers/Microsoft.Storage.Admin/locations/{2}/quotas/{3}?api-version={4}" -f $AdminUri, $SubscriptionId, $ArmLocation, $quotaName, $ApiVersion
    $RequestBody = @"
    {
        "name":"$quotaName",
        "location":"$ArmLocation",
        "properties": { 
            "capacityInGb": $capacityInGb, 
            "numberOfStorageAccounts": $numberOfStorageAccounts
        }
    }
"@
    $headers = @{ "Authorization" = "Bearer "+ $AzureStackToken }
    $storageQuota = Invoke-RestMethod -Method Put -Uri $uri -Body $RequestBody -ContentType 'application/json' -Headers $headers
    $storageQuota
}

function Get-StorageQuota
{
    param(
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [string] $quotaName
    )    

    $ApiVersion = "2015-12-01-preview"

    $uri = "{0}/subscriptions/{1}/providers/Microsoft.Storage.Admin/locations/{2}/quotas/{3}?api-version={4}" -f $AdminUri, $SubscriptionId, $ArmLocation, $quotaName, $ApiVersion

    $headers = @{ "Authorization" = "Bearer "+ $AzureStackToken }
    $storageQuota = Invoke-RestMethod -Method Get -Uri $uri -Body $RequestBody -ContentType 'application/json' -Headers $headers
    if ($storageQuota | gm -Name Value)
        {$storageQuota.Value}
    else
        {$storageQuota}
}

function New-ComputeQuota
{
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $quotaName,
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [ValidatePattern('[0-9]+')]
        [string] $vmCount = 10,
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [ValidatePattern('[0-9]+')]
        [string] $memoryLimitMB = 10240,
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [ValidatePattern('[0-9]+')]
        [string] $coresLimit = 10

    )  
    
    $ApiVersion     = "2015-12-01-preview"

    $uri = "{0}/subscriptions/{1}/providers/Microsoft.Compute.Admin/locations/{2}/quotas/{3}?api-version={4}" -f $AdminUri, $SubscriptionId, $ArmLocation, $quotaName, $ApiVersion
    $RequestBody = @"
    {
        "name":"$quotaName",
        "type":"Microsoft.Compute.Admin/quotas",
        "location":"$ArmLocation",
        "properties":{
            "virtualMachineCount":$vmCount,
            "memoryLimitMB":$memoryLimitMB,
            "coresLimit":$coresLimit
        }
    }
"@
    $headers = @{ "Authorization" = "Bearer "+ $AzureStackToken }
    $computeQuota = Invoke-RestMethod -Method Put -Uri $uri -Body $RequestBody -ContentType 'application/json' -Headers $headers
    $computeQuota
}

function Get-ComputeQuota
{
    param(
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [string] $quotaName
    )  
    
    $ApiVersion     = "2015-12-01-preview"

    $uri = "{0}/subscriptions/{1}/providers/Microsoft.Compute.Admin/locations/{2}/quotas/{3}?api-version={4}" -f $AdminUri, $SubscriptionId, $ArmLocation, $quotaName, $ApiVersion

    $headers = @{ "Authorization" = "Bearer "+ $AzureStackToken }
    $computeQuota = Invoke-RestMethod -Method Get -Uri $uri   -Headers $headers
    if ($computeQuota | gm -Name Value)
        {$computeQuota.Value}
    else
        {$computeQuota}
}

function New-NetworkQuota
{
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $quotaName,
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [ValidatePattern('[0-9]+')]
        [string] $publicIpsPerSubscription = 50,
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [ValidatePattern('[0-9]+')]
        [string] $vNetsPerSubscription = 50,
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [ValidatePattern('[0-9]+')]
        [string] $gatewaysPerSubscription = 1,
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [ValidatePattern('[0-9]+')]
        [string] $connectionsPerSubscription = 2,
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [ValidatePattern('[0-9]+')]
        [string] $loadBalancersPerSubscription = 50,
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [ValidatePattern('[0-9]+')]
        [string] $nicsPerSubscription = 100,
         [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [ValidatePattern('[0-9]+')]
        [string] $securityGroupsPerSubscription = 50


    ) 

    $vNetsPerSubscription           = 50
    $gatewaysPerSubscription        = 1
    $connectionsPerSubscription     = 2
    $loadBalancersPerSubscription   = 50
    $nicsPerSubscription            = 100
    $securityGroupsPerSubscription  = 50
    $ApiVersion                     = "2015-06-15"

    $uri = "{0}/subscriptions/{1}/providers/Microsoft.Network.Admin/locations/{2}/quotas/{3}?api-version={4}" -f $AdminUri, $SubscriptionId, $ArmLocation, $quotaName, $ApiVersion
    $id = "/subscriptions/{0}/providers/Microsoft.Network.Admin/locations/{1}/quotas/{2}" -f  $SubscriptionId, $ArmLocation, $quotaName
    $RequestBody = @"
    {
        "id":"$id",
        "name":"$quotaName",
        "type":"Microsoft.Network.Admin/quotas",
        "location":"$ArmLocation",
        "properties":{
            "maxPublicIpsPerSubscription":$publicIpsPerSubscription,
            "maxVnetsPerSubscription":$vNetsPerSubscription,
            "maxVirtualNetworkGatewaysPerSubscription":$gatewaysPerSubscription,
            "maxVirtualNetworkGatewayConnectionsPerSubscription":$connectionsPerSubscription,
            "maxLoadBalancersPerSubscription":$loadBalancersPerSubscription,
            "maxNicsPerSubscription":$nicsPerSubscription,
            "maxSecurityGroupsPerSubscription":$securityGroupsPerSubscription,
        }
    }
"@
    $headers = @{ "Authorization" = "Bearer "+ $AzureStackToken}
    $networkQuota = Invoke-RestMethod -Method Put -Uri $uri -Body $RequestBody -ContentType 'application/json' -Headers $headers
    $networkQuota
}

function Get-NetworkQuota
{
    param(
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [string] $quotaName
    ) 

    $ApiVersion                     = "2015-06-15"

    $uri = "{0}/subscriptions/{1}/providers/Microsoft.Network.Admin/locations/{2}/quotas/{3}?api-version={4}" -f $AdminUri, $SubscriptionId, $ArmLocation, $quotaName, $ApiVersion
    $id = "/subscriptions/{0}/providers/Microsoft.Network.Admin/locations/{1}/quotas/{2}" -f  $SubscriptionId, $ArmLocation, $quotaName
    $headers = @{ "Authorization" = "Bearer "+ $AzureStackToken}
    $networkQuota = Invoke-RestMethod -Method Get -Uri $uri  -Headers $headers
    if ($networkQuota | gm -Name Value)
        {$networkQuota.Value}
    else
        {$networkQuota}
}

function Get-KeyVaultQuota
{
    param(

    ) 


    $uri = "{0}/subscriptions/{1}/providers/Microsoft.Keyvault.Admin/locations/{2}/quotas?api-version=2014-04-01-preview" -f $AdminUri, $SubscriptionId, $ArmLocation
    $headers = @{ "Authorization" = "Bearer "+ $AzureStackToken }
    $kvQuota = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType 'application/json'
    $kvQuota.Value
}

function Get-SubscriptionQuota
{
    param(

    ) 
    $ApiVersion = '2015-11-01'
    $uri = "{0}/subscriptions/{1}/providers/Microsoft.Subscriptions.Admin/locations/{2}/quotas?api-version={3}" -f $AdminUri, $SubscriptionId, $ArmLocation,$ApiVersion
    $headers = @{ "Authorization" = "Bearer "+ $AzureStackToken }
    $subQuota = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType 'application/json'
    $subQuota.Value
}
#endregion

#region PowerShell Modules
Import-Module -Name AzureRM -RequiredVersion 1.2.8 -ErrorAction SilentlyContinue -ErrorVariable ErrorMsg
if ($ErrorMsg)
{
    Install-Module -Name AzureRM -RequiredVersion 1.2.8 -Force
}
Import-Module -Name AzureStack -RequiredVersion 1.2.8 -ErrorAction SilentlyContinue -ErrorVariable ErrorMsg
if ($ErrorMsg)
{
    Install-Module -Name AzureStack -RequiredVersion 1.2.8 -Force
}
#endregion

#region GitHub Utilities and templates
invoke-webrequest https://github.com/Azure/AzureStack-Tools/archive/master.zip -OutFile "$env:TEMP\master.zip"
expand-archive "$env:TEMP\master.zip" -DestinationPath C:\ -Force
Remove-Item "$env:TEMP\master.zip"

invoke-webrequest "https://github.com/Azure/AzureStack-QuickStart-Templates/archive/master.zip" -OutFile "$env:TEMP\master.zip"
expand-archive "$env:TEMP\master.zip" -DestinationPath C:\ -Force
Remove-Item "$env:TEMP\master.zip"
#endregion

#region Import Modules

Import-Module C:\AzureStack-Tools-master\Connect\AzureStack.Connect.psm1
Import-Module C:\AzureStack-Tools-master\ComputeAdmin\AzureStack.ComputeAdmin.psm1

#endregion

#region Environment and Authentication
$MASCredential = New-Object System.Management.Automation.PSCredential "$ServiceAdminUsername", (ConvertTo-SecureString "$ServiceAdminPassword" -AsPlainText -Force)
Add-AzureStackAzureRmEnvironment -AadTenant $AADTenantDomain -Name AzureStackEnv -ArmEndpoint $AdminUri
$MASEnv = Add-AzureRmAccount -EnvironmentName 'AzureStackEnv' -Credential $MASCredential
$SubscriptionId = (Get-AzureRmContext).Subscription.SubscriptionId
$AADTenantGuid = Get-AADTenantGUID -AADTenantName $AADTenantDomain
$AzureStackToken = Get-AzureStackToken `
    -Authority  $MASEnv.Context.Environment.ActiveDirectoryAuthority`
    -Resource $MASEnv.Context.Environment.ActiveDirectoryServiceEndpointResourceId `
    -AadTenantId $MASEnv.Context.Tenant.TenantId `
    -ClientId '0a7bdc5c-7b57-40be-9939-d4c5fc7cd417' `
    -Credential $MASCredential
#endregion

#region Quotas Plans and Offers

$ITComputeQuota = New-ComputeQuota -QuotaName Standard-Compute -vmCount 250 -memoryLimitMB 200400 -coresLimit 175
$ITNetworkQuota = New-NetworkQuota -QuotaName Standard-Network -publicIpsPerSubscription 75 -vNetsPerSubscription 75 -gatewaysPerSubscription 15 -connectionsPerSubscription 30 -loadBalancersPerSubscription 50 -nicsPerSubscription 75 -securityGroupsPerSubscription 75
$ITStorageQuota = New-StorageQuota -QuotaName Standard-Storage -capacityInGb 175 -numberOfStorageAccounts 100
$DEVComputeQuota = New-ComputeQuota  -QuotaName Premium-Compute -vmCount 500 -memoryLimitMB 1024000 -coresLimit 350
$DEVNetworkQuota = New-NetworkQuota -QuotaName Premium-Network -publicIpsPerSubscription 100 -vNetsPerSubscription 100 -gatewaysPerSubscription 50 -connectionsPerSubscription 100 -loadBalancersPerSubscription 100 -nicsPerSubscription 500 -securityGroupsPerSubscription 500
$DEVStorageQuota = New-StorageQuota -QuotaName Premium-Storage -capacityInGb 300 -numberOfStorageAccounts 50
$TrialComputeQuota = New-ComputeQuota -QuotaName Trial-Compute -vmCount 4 -memoryLimitMB 1024 -coresLimit 4
$TrialNetworkQuota = New-NetworkQuota -QuotaName Trial-Network -publicIpsPerSubscription 5 -vNetsPerSubscription 5 -gatewaysPerSubscription 1 -connectionsPerSubscription 2 -loadBalancersPerSubscription 5  -nicsPerSubscription 10 -securityGroupsPerSubscription 2
$TrialStorageQuota  = New-StorageQuota -QuotaName Trial-Storage -capacityInGb 10 -numberOfStorageAccounts 2
$KVQuota = Get-KeyVaultQuota
$SubscriptionQuota = Get-SubscriptionQuota

New-AzureRmResourceGroup -Name $OfferRG -Location $ArmLocation

$CasDevPlan = New-AzureRmPlan -Name Premium-plan -DisplayName Premium-Plan -ArmLocation $ArmLocation -ResourceGroup  $OfferRG -QuotaIds @($DEVComputeQuota.id,$DEVNetworkQuota.id,$DEVStorageQuota.id,$KVQuota.id)
$CasItPlan = New-AzureRmPlan -Name Standard-plan -DisplayName Standard-Plan -ArmLocation $ArmLocation -ResourceGroup  $OfferRG -QuotaIds @($ITComputeQuota.id,$ITNetworkQuota.id,$ITStorageQuota.id)
$CasTrialPlan = New-AzureRmPlan -Name trial-plan -DisplayName Trial-Plan -ArmLocation $ArmLocation -ResourceGroup  $OfferRG -QuotaIds @($TrialComputeQuota.id,$TrialNetworkQuota.id,$TrialStorageQuota.id)

New-AzureRMOffer -name Standard-offer -DisplayName Standard-Offer -ARMLocation $ArmLocation -ResourceGroup $OfferRG -BasePlanIds $CasItPlan.Id
New-AzureRMOffer -name Premium-offer -DisplayName Premium-Offer -ARMLocation $ArmLocation -ResourceGroup $OfferRG -BasePlanIds $CasDevPlan.Id
New-AzureRMOffer -name trial-offer -DisplayName Trial-Offer -State Public -ARMLocation $ArmLocation -ResourceGroup $OfferRG -BasePlanIds $CasTrialPlan.Id

New-AzureRmResourceGroup -Name $DelegatedOffersRG -Location $ArmLocation
$DelPlan = New-AzureRMPlan -Name CAS-Del-Plan -DisplayName "CAS-Delegation-Plan" -ArmLocation $ArmLocation -ResourceGroup $DelegatedOffersRG -QuotaIds @($SubscriptionQuota.id)
New-AzureRMOffer -name CAS-Delegation-offer -DisplayName CAS-Delegation-Offer -ARMLocation $ArmLocation -ResourceGroup $DelegatedOffersRG -BasePlanIds $DelPlan.Id

#endregion

#region Tags

New-AzureRMTag -Name "VM Operating System" -Value "Windows Server 2016"

#endregion

#region Configure Marketplace Syndication

cd C:\Temp

invoke-webrequest   https://raw.githubusercontent.com/Azure/AzureStack-Tools/master/Registration/RegisterWithAzure.ps1  -Outfile  RegisterwithAzure.ps1

.\RegisterwithAzure.ps1 -azureDirectory $AzureAD -azureSubscriptionId $AzureSubID -azureSubscriptionOwner $UserAccountName


#endregion

#region Platform Images

#Environment and ReAuthentication

$MASCredential = New-Object System.Management.Automation.PSCredential "$ServiceAdminUsername", (ConvertTo-SecureString "$ServiceAdminPassword" -AsPlainText -Force)
Add-AzureStackAzureRmEnvironment -AadTenant $AADTenantDomain -Name AzureStackEnv -ArmEndpoint $AdminUri
$MASEnv = Add-AzureRmAccount -EnvironmentName 'AzureStackEnv' -Credential $MASCredential
$SubscriptionId = (Get-AzureRmContext).Subscription.SubscriptionId
$AADTenantGuid = Get-AADTenantGUID -AADTenantName $AADTenantDomain
$AzureStackToken = Get-AzureStackToken `
    -Authority  $MASEnv.Context.Environment.ActiveDirectoryAuthority`
    -Resource $MASEnv.Context.Environment.ActiveDirectoryServiceEndpointResourceId `
    -AadTenantId $MASEnv.Context.Tenant.TenantId `
    -ClientId '0a7bdc5c-7b57-40be-9939-d4c5fc7cd417' `
    -Credential $MASCredential

#Install Server 2016

New-Server2016VMImage -ISOPath $ISOPath -TenantId $AADTenantDomain -AzureStackCredentials $MASCredential

# Install Ubuntu Image

#Environment and reAuthentication

$MASCredential = New-Object System.Management.Automation.PSCredential "$ServiceAdminUsername", (ConvertTo-SecureString "$ServiceAdminPassword" -AsPlainText -Force)
Add-AzureStackAzureRmEnvironment -AadTenant $AADTenantDomain -Name AzureStackEnv -ArmEndpoint $AdminUri
$MASEnv = Add-AzureRmAccount -EnvironmentName 'AzureStackEnv' -Credential $MASCredential
$SubscriptionId = (Get-AzureRmContext).Subscription.SubscriptionId
$AADTenantGuid = Get-AADTenantGUID -AADTenantName $AADTenantDomain
$AzureStackToken = Get-AzureStackToken `
    -Authority  $MASEnv.Context.Environment.ActiveDirectoryAuthority`
    -Resource $MASEnv.Context.Environment.ActiveDirectoryServiceEndpointResourceId `
    -AadTenantId $MASEnv.Context.Tenant.TenantId `
    -ClientId '0a7bdc5c-7b57-40be-9939-d4c5fc7cd417' `
    -Credential $MASCredential


invoke-webrequest https://partner-images.canonical.com/azure/azure_stack/ubuntu-14.04-LTS-microsoft_azure_stack-20170225-10.vhd.zip -OutFile "C:\Temp\Ubuntu.zip"
cd C:\Temp
expand-archive ubuntu.zip -DestinationPath . -Force
Add-VMImage -publisher "Canonical" -offer "UbuntuServer" -sku "14.04.3-LTS" -version "1.0.0" -osType Linux -osDiskLocal 'C:\Temp\trusty-server-cloudimg-amd64-disk1.vhd' -tenantID "$AADTenantGuid" -AzureStackCredentials $MASCredential

#endregion
