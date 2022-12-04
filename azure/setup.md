# 公式サイト
- https://learn.hashicorp.com/collections/terraform/azure-get-started?utm_source=terraform_io_download

# terraformのダウンロード
- https://www.terraform.io/downloads
- 展開先を**C:\terraform*として展開
- 環境変数のPATHに*C:\terraform*を追加
- terraform --version

# Azure CLIのダウンロード
- 管理者権限でPowerShellを起動し、コマンド実行
  - Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi

# Azureにログインして、サブスクリプションにアクセス
- az_login.ps1を実行
  - Set-ExecutionPolicy -Scope Process RemoteSigned
  - az login

# サブスクリプションにアクセス
- サブスクリプションIDを取得して接続
  - $subsc_id = az account show --query id --output tsv
  - az account set --subscription $subsc_id

# サービスプリンシパルを作成(Azure AD内で、terraformが操作を行うための認証トークンを取得)
- テナントIDを取得
  - $tenant_id = az account show --query tenantId --output tsv
- サブスクリプションIDを更新
  - az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subsc_id"
  - passwordとappIdの値をコピーしておく
- passwordとappIdを環境変数に格納
  - set_passwd+appId.ps1を実行
    - $Env:ARM_CLIENT_SECRET = "<PASSWORD_VALUE>"
    - $Env:ARM_CLIENT_ID = "<APPID_VALUE>"

# main.tfを作成し、デプロイする
- main.tfを作成
- terraform init
- terraform validate
- terraform apply