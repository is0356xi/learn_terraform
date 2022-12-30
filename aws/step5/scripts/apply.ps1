param(
    [Parameter(mandatory=$true)][string]$keybase_user
)

terraform fmt --recursive 
terraform fmt --recursive ../../modules

# ユーザリストが記載されたCSVファイルをJSONファイルに変換
python ../../scripts/load_users_data.py
# apply実行
terraform apply
$result = echo $?

if($result -eq "True"){
    # 暗号化されたパスワードを復号化する
    python ../../scripts/show_login_info.py $keybase_user
    # コマンドプロンプトに出力
    import-csv -Path "login_info.csv" -Header "user_name", "password" |  Format-Table -AutoSize -Wrap
}
else{
    echo "terraform apply failed."
}