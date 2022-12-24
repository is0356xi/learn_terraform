# 環境固有の変数
variable "env_params" {}

# AVDセッションホストのパラメータ
variable "avd_sessionHost_params" {}

# 作成済みのサブネット
variable "created_subnet" {}

# VMのローカル管理者情報
variable "avd_local_admin_params" {}

# ドメイン管理に関する情報
variable "dc_admin_params" {}

# ホストプール作成時のトークン
variable "registration_token" {}

# 作成済みのホストプール
variable "created_hostpool" {}