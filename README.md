# Terraformを学んでIAC生活しよう

## Step1
- terraform, Azure CLIのセットアップ
- main.tfの作成・実行

## Step2
- importする前にリソースブロックの定義が必要
  - step2/main.tfを作成

```:main.tfの一部
# xxxはimport元と一致させる必要あり
resource "azurerm_resource_group" "xxx" {
  # (resource arguments)
}
```

- Step1で作成したリソースグループをimport
  - ディレクトリ:step2にて、terraform init
    - tfstateはカレントディレクトリに生成される
    - 環境・機能ごとにtfstateを分割する→影響範囲を小さくなる、コンパイル速度が向上する
  - importr_resource.ps1で作成済みリソースグループをtfstateに書き出し
    - terraform import <resource_type> <resource_name> <Azure_resource_ID>
    
- tfstateのリソース情報をlocalsで読み込み
  - jsondecode(file("terraform.tfstate.json"))

- 既存リソースの情報を用いて新規リソース作成