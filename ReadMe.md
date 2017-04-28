Once you have deployed Azure Stack, log in as Service admin and we can start the configuration of the lab.  The scripts will do the following:

* Install the correct version of Azure RM and Azure Stack PowerShell
* Install the Azure Stack Tools
* Install the SQL/MySQL Resource Providers  **NOTE the App Service RP requires installation using the steps here: https://docs.microsoft.com/en-us/azure/azure-stack/azure-stack-app-service-overview
* Add three images to the PIR: Windows Server 2016 / Windows Server 2012 R2 / Ubuntu
* Create plans, offers, and quotas with specific quotas aligned to offers and plans
* Configure delegation plan and offer You will need to add your users to delegation and subscriptions using the instructions here
* Create a custom tag for use with the Server 2016 image
     *NOTE:  You must download the Windows Server 2016 Eval ISO either from TechNet or as part of the installation of Azure Stack.  You will need to provide the full path to the ISO. 
* Configure Marketplace Syndication 



 
Instructions
--------------- 

1 Copy either the Enterprise or Service provider script from GitHub and save to your machine, saving as a ps1 file. 
2 Run the following command to get your subscription id
*  Get-AzureRMContext
3 In the script, change following values to the ones applicable to your lab.  Save the PS1 file
 
 * $ISOPath = 'PATH TO Server 2016 ISO'
 * $2012R2Vhd = "PATH TO Server 2012 R2 VHD"
 * $AADTenantDomain = 'AAD DOMain NAME'  # ex. mydomain.onmicrosoft.com
 * $ServiceAdminUsername = 'SERVICE ADMIN ACCOUNT' # ex. serviceadmin@mydomain.onmicrosoft.com
 * $ServiceAdminPassword = 'SERVICE ADMIN PWD'
 * TenantUserName = 'TENANT ACCOUNT' # ex. tenant@mydomain.onmicrosoft.com
 * $TenantPassword = 'TENANT PWD'
 * $AzureAD = "AZURE BILLING SUBSCRIPTION"
 * $AzureSubID = "AZURE BILLING SUBSCIPTION GUID"
 * $UserAccountName = "AZURE BILLING SUBSCRIPTION OWNER"
 * $MASDomain ='AZURE STACK DOMAIN' #ex. azurestack.external
 * $RegionName='AZURE STACK REGION' #ex. local 
 * $SubscriptionId = 'TENANT SUBSCRIPTION GUID'
 
NOTE: do not change the variables as changing them will/could break the scripts
 * $AdminArmEndpoint = 'https://adminmanagement.{0}.{1}' -f $RegionName,$MASDomain
 * $TenantArmEndpoint = 'https://management.{0}.{1}' -f $RegionName,$MASDomain
 * $OfferRG='OffersandPlans'
 * $DelegatedOffersRG='CASDelegatedOffers'
     
4 Run the Enterprise/Service provider script to install the lab

NOTE: you will be asked to provide credentials during the build of the lab.  The credentials required will be your service admin account and password EXCEPT for when the registration is taking place.  This will require the service admin associated with your billing account and password
NOTE: Due to the length of time the script runs, you may need to reauthenticate.  Before installation of each of the images (end of script), a reauthentication to azure stack will occur automatically
