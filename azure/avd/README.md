# AVD環境を構築

## Todo

### ①ADDSをterraformで構築
- [Terraform registryで公開されているモジュール](https://registry.terraform.io/modules/schnerring/aadds/azurerm/latest)
- [Terraoform公式ドキュメント](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/active_directory_domain_service)
- [MS AADDSの有効化ドキュメント](https://learn.microsoft.com/ja-jp/azure/active-directory-domain-services/powershell-create-instance#create-required-azure-ad-resources)


### ②AVD基盤を構築
  - [MS公式 terraformでAVD構築](https://learn.microsoft.com/ja-jp/azure/developer/terraform/configure-azure-virtual-desktop)

### ③セッションホストを構築
- [MS公式 terraformでセッションホスト構築](https://learn.microsoft.com/ja-jp/azure/developer/terraform/create-avd-session-host)


### ④AVD利用が許可されたグループ・ユーザを作成する
  - グループを作成して組み込みロールをアタッチする
    - [MS公式 AVDユーザ RBACロール](https://learn.microsoft.com/ja-jp/azure/developer/terraform/configure-avd-rbac)
    - [Desktop Virtualization Userロール](https://learn.microsoft.com/ja-jp/azure/virtual-desktop/rbac)
  - ユーザ情報の管理  
    - csvファイルで管理する
    - terraformはjsonファイルを読み込み可能。```xxx=jsondecode(file("~~.json"))```
    - csvファイルからjsonファイルに変換するpythonスクリプトをapply前に実行する
      - **csvファイルとjsonファイルはローカルでのみ管理すればセキュリティOK?**

### ⑤FSlogix用のAzureFilesを構築
- [MS公式ドキュメント terraform](https://learn.microsoft.com/ja-jp/azure/developer/terraform/create-avd-azure-files-storage)
- 構築後、StorageAccountのActiveDirectory構成設定を確認
  - AVDユーザグループに割り当てた```Storage File Data SMB Share Contributor```ロールをもつエンティティがAzureFilesを利用できるように設定変更が必要？
--------

## メモ

### ADDSを有効化するためにサービスプリンシパルが必要
  - https://learn.microsoft.com/ja-jp/azure/active-directory-domain-services/powershell-create-instance#create-required-azure-ad-resources
  - サービスプリンシパル作成時のアプリケーションIDは決まっている
    >ID 値は、グローバル Azure の場合は 2565bd9d-da50-47d4-8b85-4c97f669dc36、他の Azure クラウドの場合は 6ba9a5d4-8456-4118-b521-9c5ca10cdf84 です。 このアプリケーション ID は変更しないでください。
 

- AADDS構築とAVD環境構築でディレクトリを分ける
  - AADDSを間違って消すと影響が大きい(誤って再作成となると1時間強時間を取られる)
  - なのでディレクトリを分けたほうが安全に開発進められる。
  - [terraform_remote_state](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state)を活用して、outputを介してデータ連携


-----

# トラブルシューティング

## サービスプリンシパルを作成する際、再認証が必要？というエラーが発生

>Error: building client: unable to obtain access token: running Azure CLI: exit status 1: ERROR: AADSTS50076: Due to a configuration change made by your administrator, or because you moved to a new location, you must use multi-factor authentication to access.....
.....
To re-authenticate, please run:
az login --scope https://graph.microsoft.com/.default

- 以下コマンドでエラー解決
  - ```az login --scope https://graph.microsoft.com/.default```    



## VM拡張機能でドメイン参加に失敗 

### Error Code 1326

```json:
{
    "code": "ComponentStatus/JoinDomainException for Option 3 meaning 'User Specified'/failed/1",
    "level": "Error",
    "displayStatus": "Provisioning failed",
    "message": "ERROR - Failed to join domain=.......
    option='NetSetupJoinDomain, NetSetupAcctCreate' (#3 meaning 'User Specified'). Error code 1326"
},
{
    "code": "ComponentStatus/JoinDomainException for Option 1 meaning 'User Specified without NetSetupAcctCreate'/failed/1",
    "level": "Error",
    "displayStatus": "Provisioning failed",
    "message": "ERROR - Failed to join domain=..... option='NetSetupJoinDomain' (#1 meaning 'User Specified without NetSetupAcctCreate'). Error code 1326"
}
```

- ~~エラーコード1326はパスワードに関するエラー？~~ → protected_settingsの値が間違っていたかも。
  - https://support.microsoft.com/en-us/topic/error-1326-when-you-change-domain-account-password-in-windows-a238729e-4b79-b9e2-ebfa-2967c91ef5bf)
  - https://support.microsoft.com/en-us/topic/error-1326-when-you-change-domain-account-password-in-windows-a238729e-4b79-b9e2-ebfa-2967c91ef5bf
  - AADDS作成時に管理者としたユーザのパスワードを変更してみる。
    - ポータルからパスワードを変更
    - tfvarsに記載しているパスワードを変更後のパスワードに修正
    - **Erro codeが変化。1326から1909に**



### Error Code 1909

```json
{
    "code": "ComponentStatus/JoinDomainException for Option 3 meaning 'User Specified'/failed/1",
    "level": "Error",
    "displayStatus": "Provisioning failed",
    "message": "ERROR - Failed to join domain..... option='NetSetupJoinDomain, NetSetupAcctCreate' (#3 meaning 'User Specified'). Error code 1909"
},
{
    "code": "ComponentStatus/JoinDomainException for Option 1 meaning 'User Specified without NetSetupAcctCreate'/failed/1",
    "level": "Error",
    "displayStatus": "Provisioning failed",
    "message": "ERROR - Failed to join domain=....., option='NetSetupJoinDomain' (#1 meaning 'User Specified without NetSetupAcctCreate'). Error code 1909"
}
```

- パスワードが要件を満たしていない？
  - https://support.logmeininc.com/pro/help/how-do-i-resolve-error-1909-when-trying-to-log-into-a-computer
  - 大文字・小文字・記号・数字で12文字にしてみる。→ **解決**