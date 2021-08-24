# Service principal and tenant details.
<#
  if using service principal to connect to azure portal
  provide the details of the app id, tennat id, client secret and 
  subscription.
  else
  provide the credential in the get-credential.
#>

#Application Id
$client_ID=""
#Tenant Id
$Tenant_ID=""
#Client Secret
$Client_Secret=""
#Azure Subscription Id
$Subscription_Id=""

#check azure portal session has expired or not
if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account))
{
        if(!$clientID -or !$clientSecret)
        {
                #loging to azure portal using service principal
                $password= $Client_Secret | ConvertTo-SecureString -AsPlainText -Force

                $credential = New-Object -TypeName System.Management.Automation.PSCredential($client_ID, $password)

                Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $Tenant_ID -Subscription $Subscription_Id
        }
        else
        {
                  #login to azure portal using login id and password.
                  $credential= Get-Credential
                  Login-AzAccount -Credential $credential 

        }

}

#declaring resource variables 
$Resource_Group_Name="TerraformRg"
$Storage_Account_Name="tfstate1726232610"
$Container_Name="tfstate"
$Location="Southeast Asia"

# create resource group
if(!(Get-AzResourceGroup -Name $Resource_Group_Name -Location $Location -ErrorAction SilentlyContinue))
{
    New-AzResourceGroup -Name $Resource_Group_Name -Location $Location
}

#check storage account exist
$Storage_Context=Get-AzStorageAccount -ResourceGroupName $Resource_Group_Name -Name $Storage_Account_Name -ErrorAction SilentlyContinue -ErrorVariable NOTFOUND

if($NOTFOUND)
{
    # Create storage account
    $Storage_Context=New-AzStorageAccount -Name $Storage_Account_Name -ResourceGroupName $Resource_Group_Name -Location $Location -SkuName Standard_LRS -AllowBlobPublicAccess $false

}

if($Storage_Context)
{ 
      
    if(!(Get-AzStorageContainer -Name $Container_Name -Context $Storage_Context.Context -ErrorAction SilentlyContinue))
    {
    
        # Create container inside storage account $Storage_Account_Nam
        New-AzStorageContainer -Name $Container_Name -Context $Storage_Context.Context -Permission Off
    }

}