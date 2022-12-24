param(
    [Parameter(mandatory=$true)][string]$csv_file_name
)

$module_path = "../../../modules"
terraform fmt --recursive
terraform fmt --recursive $module_path

# ユーザCSVファイルからデータを読み込み、jsonファイルに変換
if(test-path $csv_file_name){
    python ..\..\..\scripts\load_user_data.py $csv_file_name
}

terraform apply