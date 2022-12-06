# 環境固有の変数
variable "env_params" {}

# 作成済みのSNSトピック
variable "created_topic" {}

# SNSトピック サブスクリプションのパラメータ
variable "subscription_params" {}

# サブスクリプションのエンドポイント（データ送信先）
variable "endpoints" {}
