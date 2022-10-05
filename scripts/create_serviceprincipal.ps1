# サブスクリプションを更新
$subsc_id = az account show --query id --output tsv
az account set --subscription $subsc_id

# サービスプリンシパルを作成
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subsc_id"
