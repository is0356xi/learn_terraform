# Terraformを学んでIAC生活しよう

# Step1
**Todo**
- terraform, Azure CLIのセットアップ
- main.tfの作成・実行


# Step2
**Todo**
- 既存リソースの情報を```terraform import```で取得
- 取得した情報を基に新規リソースを作成する

**メモ**
- importする前に同一名のリソースブロックの定義が必要

```:main.tfの一部
# xxxはimport元と一致させる必要あり
resource "azurerm_resource_group" "xxx" {
  # (resource arguments)
}
```

- 新規リソースをデプロイしたタイミングで既存リソースは消える
  - IDが同じだから上書き的なノリ？

- importr_resource.ps1で作成済みリソースグループをtfstateに書き出し
  - terraform import <resource_type> <resource_name> <Azure_resource_ID>
    
- tfstateのリソース情報をlocalsで読み込み
  - jsondecode(file("terraform.tfstate.json"))


# Step3
**Todo**
- 以降の全ステップ共通
  - ディレクトリ構成のベストプラクティスを探す&Module化勉強
- Step3
  - 本番環境開発を見越して、```terraform.tfstate```をBLOBストレージで管理
  - Vnet, Subnet×2を作成
  - Nic×2を作成
  - 仮想マシンを2台作成
  - NSGを作成

(随時更新)


### 3-1
**Todo**
- Vnet, Subnet×2をterraformで作成する
- terraform.tfstateをBLOBストレージで管理する
  - [公式サイト](https://learn.microsoft.com/ja-jp/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli)
  - [環境切り替え方法](https://zenn.dev/y_megane/articles/20220406-terraform-backend-switching)
  - 3-1だけ実装し、それ以降はローカル管理に切り替え
- 今後に向けて、ディレクトリ構成のベストプラクティスを模索してみる

**メモ**
- 新規リソース作成する際は、resourceブロックの中身を空にして```terraform plan```すると楽
  - 必要な引数がエラー文に全部表示される
  - ```resource "xx" "yy"{}```の状態で```terraform plan```する
- それぞれのリソースが依存関係にあるので、そのあたりをどのようにコードで表現するか
- ついでにscriptsにスクリプトファイルまとめた