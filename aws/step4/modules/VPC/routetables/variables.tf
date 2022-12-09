# 環境固有の変数
variable "env_params" {}

# 作成済みのVPC・サブネット
variable "created_vpc" {}
variable "created_subnet" {}

# ネクストホップとなる作成済みリソース
variable "dst_resources" {}

# ルートテーブルのパラメータ
variable "route_table_params" {}