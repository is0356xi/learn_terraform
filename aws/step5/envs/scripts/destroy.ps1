param(
    [Parameter(mandatory=$true)][string]$env_name
)

terraform destroy -var-file="../$env_name/user_params.tfvars"