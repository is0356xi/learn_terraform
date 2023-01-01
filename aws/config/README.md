# AWS Configのカスタムルール
- AWS Configにカスタムルールをデプロイする手順
- ```RDK```(AWS Config Rules Development Kit) と ```RDKlib```(RDKライブラリ)を使用する

------
# Prerequisites
## AWS CLI
**インストール**
- https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html


**セットアップ**
- クレデンシャル情報を登録
  - ```~/.aws/credentials```を作成する

```sh:
[default] #プロファイル名
aws_access_key_id=<アクセスキー>
aws_secret_access_key=<シークレットアクセスキー>
```

- 基本設定を登録
  - ```~/.aws/config```を作成する

```sh:
[profile default] #プロファイル名
region=<リージョン名>
output=json
```

- 設定ファイルの読み込み
  - ```aws configure --profile <プロファイル名>```を実行


## RDK`, RDKlibのインストール
- https://github.com/awslabs/aws-config-rdk
- https://github.com/awslabs/aws-config-rdklib

```sh:
pip install rdk
pip install rdklib
```

----

# Change-triggerd Rules
設定項目が変更された時に発火するルールを作成する。

## 1. リソースタイプを指定し、ルールを定義するファイル群を作成する
- ```rdk create```コマンドを実行する
- ローカルフォルダに3つのファイルが作成される
  - ルールのロジックを記述するPythonファイル
  - ルールのロジックをテストするPythonファイル
  - RDKからAWS Configへルールをデプロイする際のパラメータが記載されたJSONファイル

```sh:
# 実行コマンド
rdk init # (~/.aws/cofig内のdefaultの情報が使用される)
rdk create <ルール名> --runtime python3.7-lib --resource_type AWS::<Resource::Type>

# 例
rdk create MFA_ENABLED_RULE --runtime python3.7-lib --resource-types AWS::IAM::User
```

## 2. ローカルフォルダに生成されたファイルを編集
- ```<RULE_NAME>.py```を編集する


## 3. AWSにRDKライブラリレイヤーをインストールする
- RDKlib Layerは```Lambdaレイヤー```のこと指す。
- インストール方法は2種類
  - マネジメントコンソール(Lambda)からインストール
  - AWS CLIでインストール

**マネジメントコンソール**
- AWS Serverless Application Repositoryでレイヤーを作成する
  - ```Lambda → 関数の作成 → AWS Serverless Applicaiton Repository``` 
  - ```サーバレスアプリケーション → rdklib → デプロイ```


## 4. LambdaがAWS ConfigにアクセスするためのIAMロールを作成
- LambdaはデフォルトだとAWSの各サービスにアクセスする権限を持っていない
- Lambda関数が呼び出された際に、Assumeロールすることで一時的に権限昇格させる。


**ポリシーファイルを作成 (修正が必要な可能性あり。以下「トラブルシューティング」参照)**
```json:
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<account-ID>:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringLike": {
          "aws:PrincipalArn": "arn:aws:iam::<account-ID>:role/rdk/*"
        }
      }
    }
  ]
}
```

**AWS CLIからIAMロールを作成**

```sh:
aws iam create-role --role-name <ロール名> --assume-role-policy-document file://<JSONファイルのパス>
```

**マネジメントコンソールから作成したロールの許可ポリシーを追加**
- ```IAM→ロール→作成したロール名→許可→AWS_ConfigRole```


**RDKに作成したロールを認識させる**

```sh:
rdk modify <ルール名> --input-parameters '{\"ExecutionRoleName\":\"<ロール名>\"}'
```

## 5. ルールをLambdaレイヤーにデプロイする

```sh
rdk deploy <ルール名> --rdklib-layer-arn <rdklib-layerのARN>
```

------------------------------
# rdk test-localの実行方法
- Configuration_itemのサンプルを取得する

```sh:
rdk sample-ci <Resource Type>
rdk sample-ci AWS::EC2::VPC 
```

- 環境変数を設定する

```sh:
$env:accountid=<アカウントID>
```

- ```mytest_templateフォルダ```をルールフォルダにコピーする
- ```mytest_utils.py```から```<ルール名>_test.py```にテスト実行モジュールを移す
- ```rdk test-local <ルール名>```を実行する



-------------------------------
# トラブルシューティング

## rdk deployにて、cloudfarmationスタックの作成に失敗する
- ドキュメント通りに進めると、pythonのruntimeに不整合が発生する
  - parameters.jsonのruntimeは```python3.6-lib```
  - Lambdaレイヤーのruntimeは```python3.7or3.8or3.9```


- **parameters.jsonのruntimeを```python3.7-lib```に変更する。**

## デプロイ成功後のルールの詳細を見ると、「評価結果がありません」「利用不可」となっている
- Lambdaの画面から```ログ```を確認すると、```AccessDenied```になっていた

```json:
{'internalErrorMessage': 'Insufficient access to perform this action.', 'internalErrorDetails': 'An error occurred (AccessDenied) when calling the AssumeRole operation: User: arn:aws:sts::<accountid>:assumed-role/VPCCONFLICTRULE-rdkLambdaRole-1A5MKMJJUD7Y8/RDK-Rule-Function-VPCCONFLICTRULE is not authorized to perform: sts:AssumeRole on resource: arn:aws:iam::<accountid>:role/lambda-to-awsconfig', 'customerErrorMessage': 'AWS Config does not have permission to assume the IAM role. Please try 1) grant the right privilege to the assume the IAM role OR 2) provide Config Rules parameter "EXECUTION_ROLE_NAME" to specify a role to execute your rule OR 3)Set Config Rules parameter "ASSUME_ROLE_MODE" to False to use your lambda role instead of default Config Role.', 'customerErrorCode': 'AccessDenied'}

```

**解決方法1**
- IAMロールの信頼関係を編集する
  - エラー文には、```arn:aws:sts::<accountid>:assumed-role/VPCCONFLICTRULE-rdkLambdaRole-1A5MKMJJUD7Y8/RDK-Rule-Function-VPCCONFLICTRULE```に対して、信頼関係がない。と記載されている

```json:
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowLambdaAssumeRole",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:sts::<account-id>:assumed-role/VPCCONFLICTRULE-rdkLambdaRole-1A5MKMJJUD7Y8/RDK-Rule-Function-VPCCONFLICTRULE"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

**解決方法3**
- ルールのパラメータに```{"AssumeRoleMode":"False"}```を追加することでエラー解決
  - Lambda関数をデプロイした際に作成されるデフォルトロールを使用する？