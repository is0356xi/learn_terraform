Param(
    [parameter(mandatory=$true)]$passwd,
    [parameter(mandatory=$true)]$appId
)

$Env:ARM_SUBSCRIPTION_ID = $subsc_id
$Env:ARM_TENANT_ID = $tenant_id
$Env:ARM_CLIENT_SECRET = $passwd
$Env:ARM_CLIENT_ID = $appId