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


### 3-2
**Todo**
- NIC×2、仮想マシン2台を作成する

**メモ**
- Module開発手順
  - 正攻法 
    - Terraform Registyを確認して、必要な引数などをうめていく
  - 邪道
    - moduleディレクトリ下に作成したいモジュールのフォルダを作成
    - その配下に```xxx.tf```を作成する
    - ルートモジュールで読み込み ```module xxx{source = module/xxx}```
    - ```resource "xx" "yy"{}```の状態で```terraform plan```する
    - エラーで表示された変数を```xxx.tf```と同じ階層の```xxx_vars.tf```に書き出す
    - xxx.tf側でxxx_vars.tfの内容を参照する
    - エラーがなくなるまで```terraform plan```でデバッグ


### 3-3
**Todo**
- UDR(user defined route)、NSG(netwrok security group)を作成する
- Data Sourceを利用して、既存リソースを取得する
- 取得した既存リソースにUDR, NSGをアタッチする

**メモ**
- networkモジュールのサブモジュールとしてUDR,NSGを作成
- 既存リソースの取得について参考情報
  - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources 
- 多重階層のループ処理にはコツがいる
  - https://yamavlog.com/gcp-terraform-multiple-loops/ 
- マップ(key=value形式)のリストの各要素をindexで指定したい場合にはvaluesを使う
  - https://www.terraform.io/language/functions/values
  
```:
> values({a=3, c=2, d=1})
# key=valueのvalueを取り出してリストに変換
[3,2,1,]
```


- 既存のサブネットは```data azurerm_subnet```で取得する


### 3-4
**Todo**
- 3-3までに作成した環境に対して、Terraformerを使ってリソース情報を吸い上げ
- 全リソースが一つのtfファイルに吐き出されるので、モジュールに切り分けていく

**メモ**
- Terraformerのインストール
  - go言語のインストール
    - https://go.dev/dl/
  - バイナリファイルをダウンロードしてリネーム
    - https://github.com/GoogleCloudPlatform/terraformer/releases
    - **mv .\terraformer-all-windows-amd64 .\terraformer.exe**
  - PATHを通す
    - Pathにフォルダを追加する
    - ↑ terraformer.exeをダウンロードしたフォルダ
  - **terraformer --version**で動作確認

- usage
  - import先となるディレクトリを作る
  - import対象となるリソースのプロバイダー・バージョンファイルを作る
    - azurerm, azureadなどはここで指定？ 

```javascript:version.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
}
```

  - **terraformer import ~~~**を実行する
    - azureはタグでの**--filter**が実装されてないっぽい
    - filterする機能を実現するにはどうする？
    - terraformer import azure -R <リソースグループ名> --path-pattern <インポート先のパス>でいけそう



### 4-1
**Todo**
- terraformをaws環境に対応させる
- VPC, subnet, EC2をAWSコンソールから作成
- terraformerでimportし、コード化する(VPC×1, サブネット×2)

**メモ**
クレデンシャル情報の扱い３つ
- ①環境変数に埋め込む
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY

- ②apply実行時に変数として渡す
  - **.tfvarsの利用が推奨されている**

```terraform.tfvars:python
aws_access_key = "AKIAXXXXXXXXXXXXXXXXXX"
aws_secret_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```

```providers.tf:python
variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "ap-northeast-1"
}
```
- ③apply時に引数として指定する

```:sh
terraform apply \
-var 'access_key=AKIAXXXXXXXXXXXXXXXXXX' \
-var 'secret_key=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
```


- terraformerコマンド
  - aws cliの設定ファイルを作成
    - ~/.aws/credentials
    - ~/.aws/config
  - 作成したファイルが読み込まれるようにterraformerコマンドを実行


```sh:--profileオプションで設定ファイルを読み込み
terraformer import aws -r='*' -f="Name=tags.Name;Value=<Nameタグの値>" --profile=<プロファイル名>
```

```sh:コマンド例
# tf_testというNameタグが付いたリソースのみをimport
# 各リソースを個別のtfファイルに吐き出してくれる

terraformer import aws -r='*' -f="Name=tags.Name;Value=tf_test" --path-pattern=generated/resources/　--profile=dev
```

### 4-2
**Todo**
- IAMユーザ・グループを作成し、ポリシーをアタッチ
- ユーザのログイン情報をterraformで作成する
  - keybaseを用いて、公開鍵暗号でパスワードやアクセスキーを暗号化
  - tfstateに書き込まれるデータが暗号化される


**メモ**
- keybaseの環境構築
  - ダウンロード：https://keybase.io/download
  - ユーザを作成(keybase:に指定するユーザ名となる)
  - PGPキーを生成 (公開鍵が作成され、keybaseに登録しているデバイスから復号化が可能に)
  - [参考](https://qiita.com/ldr/items/427f6cf7ed14f4187cd2)

- 復号化のコマンド
  - keybase pgp decrypt -S <ユーザ名>

### 4-3
**Todo**
- EC2一台を作成
- SNSの設定をコンソールから行う
  - SNSトピックを作成
  - サブスクライブし、メール通知を行えるよう設定
- CloudWatchの設定をコンソールから行う
  - アラーム：EC2のCPU使用率に応じてSNSトピックにメッセージを発行
  - ダッシュボード：いくつかのメトリクスとアラームを可視化・保存
  - イベント：EC2の状態変化をトリガーにSNSトピックにメッセージを発行
- 上記リソースのCloudWatchダッシュボード以外をコード化

**メモ**
- EventBridgeからメールが来ない
  - イベントの検知はできてそう