#MUST be run from HOST Server
#Requires -RunAsAdministrator
$ISOPath = 'PATH TO Server 2016 ISO'
$2012R2Vhd = "PATH TO Server 2012 R2 VHD"
$AADTenantDomain = 'AAD DOMain NAME'  # ex. mydomain.onmicrosoft.com
$ServiceAdminUsername = 'SERVICE ADMIN ACCOUNT' # ex. serviceadmin@mydomain.onmicrosoft.com
$ServiceAdminPassword = 'SERVICE ADMIN PWD'
$TenantUserName = 'TENANT ACCOUNT' # ex. tenant@mydomain.onmicrosoft.com
$TenantPassword = 'TENANT PWD'
$AzureAD = "AZURE BILLING SUBSCRIPTION"
$AzureSubID = "AZURE BILLING SUBSCIPTION GUID"
$UserAccountName = "AZURE BILLING SUBSCRIPTION OWNER"
$MASDomain ='AZURE STACK DOMAIN' #ex. azurestack.external
$RegionName='AZURE STACK REGION' #ex. local 
$AdminArmEndpoint = 'https://adminmanagement.{0}.{1}' -f $RegionName,$MASDomain
$TenantArmEndpoint = 'https://management.{0}.{1}' -f $RegionName,$MASDomain
$OfferRG='OffersandPlans'
$DelegatedOffersRG='CASDelegatedOffers'
$SubscriptionId = 'TENANT SUBSCRIPTION GUID'

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
        [string] $numberOfStorageAccounts = 20,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $AdminUri,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $SubscriptionId,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $ArmLocation,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $Token

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
    $headers = @{ "Authorization" = "Bearer "+ $Token }
    $storageQuota = Invoke-RestMethod -Method Put -Uri $uri -Body $RequestBody -ContentType 'application/json' -Headers $headers
    $storageQuota
}

function Get-StorageQuota
{
    param(
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [string] $quotaName,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $AdminUri,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $SubscriptionId,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $ArmLocation,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $Token
    )    

    $ApiVersion = "2015-12-01-preview"

    $uri = "{0}/subscriptions/{1}/providers/Microsoft.Storage.Admin/locations/{2}/quotas/{3}?api-version={4}" -f $AdminUri, $SubscriptionId, $ArmLocation, $quotaName, $ApiVersion

    $headers = @{ "Authorization" = "Bearer "+ $Token }
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
        [string] $coresLimit = 10,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $AdminUri,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $SubscriptionId,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $ArmLocation,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $Token
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
    $headers = @{ "Authorization" = "Bearer "+ $Token }
    $computeQuota = Invoke-RestMethod -Method Put -Uri $uri -Body $RequestBody -ContentType 'application/json' -Headers $headers
    $computeQuota
}

function Get-ComputeQuota
{
    param(
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [string] $quotaName,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $AdminUri,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $SubscriptionId,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $ArmLocation,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $Token
    )  
    
    $ApiVersion     = "2015-12-01-preview"

    $uri = "{0}/subscriptions/{1}/providers/Microsoft.Compute.Admin/locations/{2}/quotas/{3}?api-version={4}" -f $AdminUri, $SubscriptionId, $ArmLocation, $quotaName, $ApiVersion

    $headers = @{ "Authorization" = "Bearer "+ $Token }
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
        [string] $securityGroupsPerSubscription = 50,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $AdminUri,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $SubscriptionId,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $ArmLocation,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $Token
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
    $headers = @{ "Authorization" = "Bearer "+ $Token}
    $networkQuota = Invoke-RestMethod -Method Put -Uri $uri -Body $RequestBody -ContentType 'application/json' -Headers $headers
    $networkQuota
}

function Get-NetworkQuota
{
    param(
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]    
        [string] $quotaName,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $AdminUri,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $SubscriptionId,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $ArmLocation,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $Token
    ) 

    $ApiVersion                     = "2015-06-15"

    $uri = "{0}/subscriptions/{1}/providers/Microsoft.Network.Admin/locations/{2}/quotas/{3}?api-version={4}" -f $AdminUri, $SubscriptionId, $ArmLocation, $quotaName, $ApiVersion
    $id = "/subscriptions/{0}/providers/Microsoft.Network.Admin/locations/{1}/quotas/{2}" -f  $SubscriptionId, $ArmLocation, $quotaName
    $headers = @{ "Authorization" = "Bearer "+ $Token}
    $networkQuota = Invoke-RestMethod -Method Get -Uri $uri  -Headers $headers
    if ($networkQuota | gm -Name Value)
        {$networkQuota.Value}
    else
        {$networkQuota}
}

function Get-KeyVaultQuota
{
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $AdminUri,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $SubscriptionId,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $ArmLocation,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $Token
    ) 


    $uri = "{0}/subscriptions/{1}/providers/Microsoft.Keyvault.Admin/locations/{2}/quotas?api-version=2014-04-01-preview" -f $AdminUri, $SubscriptionId, $ArmLocation
    $headers = @{ "Authorization" = "Bearer "+ $Token }
    $kvQuota = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType 'application/json'
    $kvQuota.Value
}

function Get-SubscriptionQuota
{
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $AdminUri,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $SubscriptionId,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $ArmLocation,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]    
        [string] $Token
    ) 
    $ApiVersion = '2015-11-01'
    $uri = "{0}/subscriptions/{1}/providers/Microsoft.Subscriptions.Admin/locations/{2}/quotas?api-version={3}" -f $AdminUri, $SubscriptionId, $ArmLocation,$ApiVersion
    $headers = @{ "Authorization" = "Bearer "+ $Token }
    $subQuota = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType 'application/json'
    $subQuota.Value
}
#endregion

#region PowerShell Modules
Import-Module -Name AzureRM -RequiredVersion 1.2.9 -ErrorAction SilentlyContinue -ErrorVariable ErrorMsg
if ($ErrorMsg)
{
    Install-Module -Name AzureRM -RequiredVersion 1.2.9 -Force
}
Import-Module -Name AzureStack -RequiredVersion 1.2.9 -ErrorAction SilentlyContinue -ErrorVariable ErrorMsg
if ($ErrorMsg)
{
    Install-Module -Name AzureStack -RequiredVersion 1.2.9 -Force
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
$ServiceAdminCreds = New-Object System.Management.Automation.PSCredential "$ServiceAdminUsername", (ConvertTo-SecureString "$ServiceAdminPassword" -AsPlainText -Force)
$TenantCreds = New-Object System.Management.Automation.PSCredential "$TenantUsername", (ConvertTo-SecureString "$TenantPassword" -AsPlainText -Force)
Add-AzureStackAzureRmEnvironment -Name AzureStackEnv -ArmEndpoint $AdminArmEndpoint
$MASEnv = Add-AzureRmAccount -EnvironmentName 'AzureStackEnv' -Credential $ServiceAdminCreds
$SubID = $MASEnv.Context.Subscription.SubscriptionId
$ADTenantID = $MASEnv.Context.Tenant.TenantId
$AzureStackToken = Get-AzureStackToken `
    -Authority  $MASEnv.Context.Environment.ActiveDirectoryAuthority`
    -Resource $MASEnv.Context.Environment.ActiveDirectoryServiceEndpointResourceId `
    -AadTenantId $ADTenantID `
    -ClientId '0a7bdc5c-7b57-40be-9939-d4c5fc7cd417' `
    -Credential $ServiceAdminCreds
#endregion

#region #Install Resource Providers

invoke-webrequest https://aka.ms/azurestackmysqlrptp3 -OutFile "C:\Temp\MySQLRP.zip"
cd C:\Temp
expand-archive MySQLRP.zip -DestinationPath .\MySQLRP -Force
del MySQLRP.zip -Force

$vmLocalAdminPass = ConvertTo-SecureString "$ServiceAdminPassword" -AsPlainText -Force
$vmLocalAdminCreds = New-Object System.Management.Automation.PSCredential ("mysqlrpadmin", $vmLocalAdminPass)

$AADAdminPass = ConvertTo-SecureString "$ServiceAdminPassword" -AsPlainText -Force
$AADAdminCreds = New-Object System.Management.Automation.PSCredential ( $ServiceAdminUsername, $AADAdminPass)

cd .\MySQLRP
.\DeployMySQLProvider.ps1 -DirectoryTenantID $SubscriptionId -AzCredential $AADAdminCreds -VMLocalCredential $vmLocalAdminCreds -ResourceGroupName "System.MySql" -VmName "mysqlrp" -ArmEndpoint $AdminArmEndpoint -TenantArmEndpoint $TenantArmEndpoint -SilentInstall

#SQL RP

invoke-webrequest https://aka.ms/azurestacksqlrptp3 -OutFile "C:\Temp\SQLRP.zip"
cd C:\Temp
expand-archive SQLRP.zip -DestinationPath .\SQLRP -Force
del SQLRP.zip -Force

$vmLocalAdminPass = ConvertTo-SecureString "$ServiceAdminPassword" -AsPlainText -Force ` 
$vmLocalAdminCreds = New-Object System.Management.Automation.PSCredential ("sqlrpadmin", $vmLocalAdminPass) `

$AADAdminPass = ConvertTo-SecureString "$ServiceAdminPassword" -AsPlainText -Force `
$AADAdminCreds = New-Object System.Management.Automation.PSCredential ($ServiceAdminUsername,$ServiceAdminPassword) `

cd .\SQLRP

.\DeploySQLProvider.ps1 -DirectoryTenantID $SubscriptionId -AzCredential $AADAdminCreds -VMLocalCredential $vmLocalAdminCreds -ResourceGroupName "System.Sql" -VmName "sqlrp" -ArmEndpoint $AdminArmEndpoint -TenantArmEndpoint $TenantArmEndpoint -SilentInstall


#App Service RP

#Register RPs

Register-AllAzureRmProvidersOnAllSubscriptions

#endregion

#region Quotas Plans and Offers
$CASComputeQuota = New-ComputeQuota -Token $AzureStackToken -AdminUri $AdminArmEndpoint -SubscriptionId $SubID -ArmLocation $RegionName -QuotaName CAS-Compute -vmCount 100 -memoryLimitMB 102400 -coresLimit 200
$CASNetworkQuota = New-NetworkQuota -Token $AzureStackToken -AdminUri $AdminArmEndpoint -SubscriptionId $SubID -ArmLocation $RegionName -QuotaName CAS-Network -publicIpsPerSubscription 50 -vNetsPerSubscription 50 -gatewaysPerSubscription 10 -connectionsPerSubscription 20 -loadBalancersPerSubscription 50 -nicsPerSubscription 100 -securityGroupsPerSubscription 50
$CASStorageQuota = New-StorageQuota -Token $AzureStackToken -AdminUri $AdminArmEndpoint -SubscriptionId $SubID -ArmLocation $RegionName -QuotaName CAS-Storage -capacityInGb 100 -numberOfStorageAccounts 20
$ITComputeQuota = New-ComputeQuota -Token $AzureStackToken -AdminUri $AdminArmEndpoint -SubscriptionId $SubID -ArmLocation $RegionName -QuotaName CAS-IT-Compute -vmCount 250 -memoryLimitMB 200400 -coresLimit 175
$ITNetworkQuota = New-NetworkQuota -Token $AzureStackToken -AdminUri $AdminArmEndpoint -SubscriptionId $SubID -ArmLocation $RegionName -QuotaName CAS-IT-Network -publicIpsPerSubscription 75 -vNetsPerSubscription 75 -gatewaysPerSubscription 15 -connectionsPerSubscription 30 -loadBalancersPerSubscription 50 -nicsPerSubscription 250 -securityGroupsPerSubscription 75
$ITStorageQuota = New-StorageQuota -Token $AzureStackToken -AdminUri $AdminArmEndpoint -SubscriptionId $SubID -ArmLocation $RegionName -QuotaName CAS-IT-Storage -capacityInGb 175 -numberOfStorageAccounts 100
$DEVComputeQuota = New-ComputeQuota  -Token $AzureStackToken -AdminUri $AdminArmEndpoint -SubscriptionId $SubID -ArmLocation $RegionName -QuotaName CAS-Dev-Compute -vmCount 500 -memoryLimitMB 1024000 -coresLimit 350
$DEVNetworkQuota = New-NetworkQuota -Token $AzureStackToken -AdminUri $AdminArmEndpoint -SubscriptionId $SubID -ArmLocation $RegionName -QuotaName CAS-Dev-Network -publicIpsPerSubscription 100 -vNetsPerSubscription 100 -gatewaysPerSubscription 50 -connectionsPerSubscription 100 -loadBalancersPerSubscription 100 -nicsPerSubscription 500 -securityGroupsPerSubscription 500
$DEVStorageQuota = New-StorageQuota -Token $AzureStackToken -AdminUri $AdminArmEndpoint -SubscriptionId $SubID -ArmLocation $RegionName -QuotaName CAS-Dev-Storage -capacityInGb 300 -numberOfStorageAccounts 50
$TrialComputeQuota = New-ComputeQuota -Token $AzureStackToken -AdminUri $AdminArmEndpoint -SubscriptionId $SubID -ArmLocation $RegionName -QuotaName Trial-Compute -vmCount 4 -memoryLimitMB 1024 -coresLimit 4
$TrialNetworkQuota = New-NetworkQuota -Token $AzureStackToken -AdminUri $AdminArmEndpoint -SubscriptionId $SubID -ArmLocation $RegionName -QuotaName Trial-Network -publicIpsPerSubscription 5 -vNetsPerSubscription 5 -gatewaysPerSubscription 1 -connectionsPerSubscription 2 -loadBalancersPerSubscription 5  -nicsPerSubscription 10 -securityGroupsPerSubscription 5
$TrialStorageQuota  = New-StorageQuota -Token $AzureStackToken -AdminUri $AdminArmEndpoint -SubscriptionId $SubID -ArmLocation $RegionName -QuotaName Trial-Storage -capacityInGb 10 -numberOfStorageAccounts 2
$KVQuota = Get-KeyVaultQuota -Token $AzureStackToken -AdminUri $AdminArmEndpoint -SubscriptionId $SubID -ArmLocation $RegionName
$SubscriptionQuota = Get-SubscriptionQuota -Token $AzureStackToken -AdminUri $AdminArmEndpoint -SubscriptionId $SubID -ArmLocation $RegionName

New-AzureRmResourceGroup -Name $OfferRG -Location $RegionName

$CasFinPlan = New-AzureRmPlan -Name cas-fin-plan -DisplayName CAS-Finance-Plan -ArmLocation $RegionName -ResourceGroup  $OfferRG -QuotaIds @($CASComputeQuota.id,$CASNetworkQuota.id,$CASStorageQuota.id,$KVQuota.id)
$CasHrPlan = New-AzureRmPlan -Name cas-hr-plan -DisplayName CAS-HR-Plan -ArmLocation $RegionName -ResourceGroup  $OfferRG -QuotaIds  @($CASComputeQuota.id,$CASNetworkQuota.id,$CASStorageQuota.id)
$CasDevPlan = New-AzureRmPlan -Name cas-dev-plan -DisplayName CAS-DEV-Plan -ArmLocation $RegionName -ResourceGroup  $OfferRG -QuotaIds @($DEVComputeQuota.id,$DEVNetworkQuota.id,$DEVStorageQuota.id,$KVQuota.id)
$CasItPlan = New-AzureRmPlan -Name cas-it-plan -DisplayName CAS-IT-Plan -ArmLocation $RegionName -ResourceGroup  $OfferRG -QuotaIds @($ITComputeQuota.id,$ITNetworkQuota.id,$ITStorageQuota.id)
$CasTrialPlan = New-AzureRmPlan -Name trial-plan -DisplayName Trial-Plan -ArmLocation $RegionName -ResourceGroup  $OfferRG -QuotaIds @($TrialComputeQuota.id,$TrialNetworkQuota.id,$TrialStorageQuota.id)

New-AzureRMOffer -name CAS-HR-offer -DisplayName CAS-HR-Offer -State Public -ARMLocation $RegionName -ResourceGroup $OfferRG -BasePlanIds $CasHrPlan.Id
New-AzureRMOffer -name CAS-FIN-offer -DisplayName CAS-Fin-Offer -State Public -ARMLocation $RegionName -ResourceGroup $OfferRG -BasePlanIds $CasFinPlan.Id
New-AzureRMOffer -name CAS-IT-offer -DisplayName CAS-IT-Offer -ARMLocation $RegionName -ResourceGroup $OfferRG -BasePlanIds $CasItPlan.Id
New-AzureRMOffer -name CAS-Dev-offer -DisplayName CAS-Dev-Offer -ARMLocation $RegionName -ResourceGroup $OfferRG -BasePlanIds $CasDevPlan.Id
New-AzureRMOffer -name trial-offer -DisplayName Trial-Offer -State Public -ARMLocation $RegionName -ResourceGroup $OfferRG -BasePlanIds $CasTrialPlan.Id

New-AzureRmResourceGroup -Name $DelegatedOffersRG -Location $RegionName
$DelPlan = New-AzureRMPlan -Name CAS-Del-Plan -DisplayName "CAS-Delegation-Plan" -ArmLocation $RegionName -ResourceGroup $DelegatedOffersRG -QuotaIds @($SubscriptionQuota.id)
New-AzureRMOffer -name CAS-Delegation-offer -DisplayName CAS-Delegation-Offer -ARMLocation $RegionName -ResourceGroup $DelegatedOffersRG -BasePlanIds $DelPlan.Id
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

#Install Server 2016

#Reauthentication
$ServiceAdminCreds = New-Object System.Management.Automation.PSCredential "$ServiceAdminUsername", (ConvertTo-SecureString "$ServiceAdminPassword" -AsPlainText -Force)
$TenantCreds = New-Object System.Management.Automation.PSCredential "$TenantUsername", (ConvertTo-SecureString "$TenantPassword" -AsPlainText -Force)
Add-AzureStackAzureRmEnvironment -Name AzureStackEnv -ArmEndpoint $AdminArmEndpoint
$MASEnv = Add-AzureRmAccount -EnvironmentName 'AzureStackEnv' -Credential $ServiceAdminCreds
$SubID = $MASEnv.Context.Subscription.SubscriptionId
$ADTenantID = $MASEnv.Context.Tenant.TenantId
$AzureStackToken = Get-AzureStackToken `
    -Authority  $MASEnv.Context.Environment.ActiveDirectoryAuthority`
    -Resource $MASEnv.Context.Environment.ActiveDirectoryServiceEndpointResourceId `
    -AadTenantId $ADTenantID `
    -ClientId '0a7bdc5c-7b57-40be-9939-d4c5fc7cd417' `
    -Credential $ServiceAdminCreds

New-Server2016VMImage -ISOPath $ISOPath -TenantId $AADTenantDomain -AzureStackCredentials $MASCredential -EnvironmentName 'AzureStackEnv' -IncludeLatestCU -Version Both -Net35 $True

# Windows Server 2012 R2 Image

Add-VMImage -publisher MicrosoftWindowsServer `
            -offer WindowsServer `
            -sku '2012-R2-Datacenter' `
            -version '1.0.0' `
            -osType Windows `
            -tenantID $AADTenantDomain `
            -location 'local' `
            -osDiskLocalPath $2012R2Vhd  `
            -CreateGalleryItem $true `
            -azureStackCredentials $AdfsCredentials `
            -EnvironmentName 'AzureStackEnv'

#Install Ubuntu Image

#Reauthentication
$ServiceAdminCreds = New-Object System.Management.Automation.PSCredential "$ServiceAdminUsername", (ConvertTo-SecureString "$ServiceAdminPassword" -AsPlainText -Force)
$TenantCreds = New-Object System.Management.Automation.PSCredential "$TenantUsername", (ConvertTo-SecureString "$TenantPassword" -AsPlainText -Force)
Add-AzureStackAzureRmEnvironment -Name AzureStackEnv -ArmEndpoint $AdminArmEndpoint
$MASEnv = Add-AzureRmAccount -EnvironmentName 'AzureStackEnv' -Credential $ServiceAdminCreds
$SubID = $MASEnv.Context.Subscription.SubscriptionId
$ADTenantID = $MASEnv.Context.Tenant.TenantId
$AzureStackToken = Get-AzureStackToken `
    -Authority  $MASEnv.Context.Environment.ActiveDirectoryAuthority`
    -Resource $MASEnv.Context.Environment.ActiveDirectoryServiceEndpointResourceId `
    -AadTenantId $ADTenantID `
    -ClientId '0a7bdc5c-7b57-40be-9939-d4c5fc7cd417' `
    -Credential $ServiceAdminCreds

invoke-webrequest https://partner-images.canonical.com/azure/azure_stack/ubuntu-14.04-LTS-microsoft_azure_stack-20170225-10.vhd.zip -OutFile "C:\Temp\Ubuntu.zip"
cd C:\Temp
expand-archive ubuntu.zip -DestinationPath . -Force
Add-VMImage -publisher "Canonical" -offer "UbuntuServer" -sku "14.04.3-LTS" -version "1.0.0" -osType Linux -osDiskLocal 'C:\Temp\trusty-server-cloudimg-amd64-disk1.vhd' -tenantID "$AADTenantDomain" -AzureStackCredentials $MASCredential -EnvironmentName 'AzureStackEnv' 

#endregion

