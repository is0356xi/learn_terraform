Param(
    [parameter(mandatory=$true)]$passwd,
    [parameter(mandatory=$true)]$appId
)

$Env:ARM_SUBSCRIPTION_ID = az account show --query id --output tsv
$Env:ARM_TENANT_ID = az account show --query tenantId --output tsv
$Env:ARM_CLIENT_SECRET = $passwd
$Env:ARM_CLIENT_ID = $appId