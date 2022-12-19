param(
    [Parameter(mandatory=$true)][string]$env_name
)

terraform fmt --recursive 
terraform fmt --recursive ../../modules

# ユーザリストが記載CSVファイルからデータを読み込み
[string] $user_params=(python ../scripts/load_users_data.py $env_name)

# tfvarsファイルにデータを書き出し
$file="user_params.tfvars" 
"user_params=" + $user_params.Replace("'", '"') | Out-File -Encoding "UTF8" $file

# apply実行
terraform apply -var-file="../$env_name/$file"

# 暗号化されたパスワードを復号化する
python ../scripts/show_login_info.py $env_name
import-csv -Path "login_info.csv" -Header "user_name", "password" |  Format-Table -AutoSize -Wrap