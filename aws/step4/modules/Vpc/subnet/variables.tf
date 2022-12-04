/*
main側から呼び出される際に指定された変数を受け取る
*/

# 環境固有の変数
variable "env_params" {}

# サブネットのパラメータ
variable subnet_params {}

# 関連づけるVPCの情報
variable created_vpc {}