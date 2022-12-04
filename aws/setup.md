# IAM認証情報を作成する
- AWSコンソールから発行する
  - IAM→ユーザ→認証情報→アクセスキー→アクセスキーの作成→.csvファイルのダウンロード


# terraform.tfvarsの作成
- terraform.tfvarsを作成し、アクセスキーの情報を記述する

```js:terraform.tfvars
aws_access_key = ""
aws_secret_key = ""
```

- terraform.tfvarsをapply時に読み込まれるようにする

```js:providers.tf
variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = var.env_params.region
}
```

- terraform.tfvarsをバージョン管理の対象外とする
  - git管理の場合は、.gitignoreにファイルを追加


# AWS CLIの環境構築
- MSIインストーラをダウンロードして実行
  - https://awscli.amazonaws.com/AWSCLIV2.msi
- プロンプトを閉じてからawsコマンドの実行確認


# AWS CLIの環境設定
- クレデンシャル情報を登録
  - ```~/.aws/credentials```を作成する

```sh:
[dev] #プロファイル名
aws_access_key_id=<アクセスキー>
aws_secret_access_key=<シークレットアクセスキー>
```

- 基本設定を登録
  - ```~/.aws/config```を作成する

```sh:
[profile dev] #プロファイル名
region=<リージョン名>
output=json
```


- 設定ファイルの読み込み
  - ```aws configure --profile <プロファイル名>```を実行
