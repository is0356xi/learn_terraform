Param(
    # Azure Portal上で名前=xxxとなっているリソースグループの場合
    [parameter(mandatory=$true)]$tf_type,  # azurerm_resource_group
    [parameter(mandatory=$true)]$tf_name,  # xxx
    [parameter(mandatory=$true)]$az_id     # Azure Portalから対象リソースのIDをコピー
)

# 既存リソースのimportし、JSON形式でtfstateを保存する
terraform import $tf_type"."$tf_name $az_id | Out-Null
Copy-Item -Path .\terraform.tfstate -Destination .\terraform.tfstate.json