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


# Step4 AWS

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
  - イベントの検知はできてそう→トピックのアクセスポリシーが足りない
  - トピックに対して、aws.events.comからのアクセスを許可するポリシーが必要


### 4-4
**Todo**
- keybaseのユーザ名をtfvasrから読み込むようにする
- EC2に対して、Pingのための設定を追加
  - セキュリティグループでICMPを許可する
  - ルートテーブルを追加
- VPCにインターネットゲートウェイをアタッチする
- SNSトピックにポリシーを追加
  - EventBridgeからのパブリッシュを許可する

**メモ**
- セキュリティグループの作成・アタッチについて
  - セキュリティグループはVPC単位で管理されている
  - 手順1: VPC_IDを指定してセキュリティグループを作成
  - 手順2: EC2などのリソース作成時に、セキュリティグループのIDを指定


- セキュリティグループでpingを許可する時
  - from_portにICMPタイプ番号を指定
  - to_portにICMPコード番号を指定
  - エコー要求を許可する時は
    - ```from_port=8,  to_port=0```となる。

- dynamicを使った二重ループ
  - 多重階層の変数をループで回す方法
    - https://developer.hashicorp.com/terraform/language/expressions/dynamic-blocks
  - ~~for_eachでリソースを作成する時は、Dynamic使えない？~~
    - length-countで作成する際は、通常のdynamicの使い方でいける←azurermの時だけかも？
    - awsの方は、for_eachでSGリソース作成時、その中でDynamic構文を使ってrule作成できた。


- routetableのルートの指定方法は二種類
  - オブジェクトを指定
    - route{}
    - dynamic構文で複数のルートを指定可能
  - オブジェクトのリストを指定
    - [{cidr_block=xxxxx, gateway_id=yyyy}]
    - https://developer.hashicorp.com/terraform/language/attr-as-blocks


- routetableのnext_hopの指定方法
  - [aws_route_tableの属性値](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)
    - vpc_id
    - route{}
      - cidr_block/ipv6_cidr_block/destination_prefix_list_id
      - gateway_id/instance_id/vpc_endpoint_idなど
  - ネクストホップの種類が複数ある
    - gateway_id, instance_id, vpc_endpoint_idなど  
    - dynamicでroute{}を複数作る際、ネクストホップの種類によってcontentの属性を変える必要がある。
      - nexthopがIGWの場合 → gateway_id = xxxxx
      - nexthopがEC2の場合 → incstace_id = yyyyy
  - 三項演算子&nullを指定することで、動的に属性値を指定する。

```js:
# 変数の定義例
variable "route_table_params" {
  default = {
    routetable1 = {
      routes = {
        to_internet_gateway = {
          destination = "0.0.0.0/0"
          type_dst    = "gateway"
          next_hop    = "igw1"
        },
        to_ec2 = {
          destination = "100.0.0.0/24"
          type_dst    = "instance"
          next_hop    = "cw_test_ec2"
        }
      }
    }
  }
}

variable dst_resources {
  default = {
    gateway  = ＜作成済みIGWのオブジェクト＞  
    instance = ＜作成済みEC2のオブジェクト＞
  }
}

# aws_route_tableブロックの中の、dynamic構文の例
dynamic "route" {
    for_each = var.route_table_params.routes
    content {
      cidr_block = route.value.destination

      # type_dstによって、next_hopの種類を判定する
      gateway_id  = route.value.type_dst == "gateway" ? var.dst_resources["gateway"][route.value.next_hop].id : null
      instance_id = route.value.type_dst == "instance" ? var.dst_resources["instance"][route.value.next_hop].id : null
    }
  }
```


- SNSトピックに対して、EventsBridgeがパブリッシュできるようにする
  - トピックにアタッチされているポリシーにstatementを追加する必要がある
  - １．一度トピックを作成する
  - ２．トピックにアタッチされたポリシーをコピーしてjsonファイルに保存
  - ３．jsonファイルをfile()で読み込んでSNSトピックに割り当てるterraformコードを書く
    - a.file()で読み込み、jsondecode()で辞書型にする
    - ```b.アカウントIDやトピックARNなどを変数から読み込みように修正[(参考)](https://qiita.com/mj69/items/66e841f27c4771738bfd)```
    - c.EventsBridgeがパブリッシュするためのstatement{}を**b**に追加