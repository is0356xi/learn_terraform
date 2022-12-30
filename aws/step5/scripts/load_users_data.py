import csv
import sys
import json

def load_csv(csv_path):
    row_data = []
    with open(csv_path, 'r') as f:
        rows = csv.reader(f)
        # ヘッダーをスキップ
        header = next(rows)
        header = [_rlstrip(col) for col in header]
        for row in rows:
            row_data.append([_rlstrip(col) for col in row])
        f.close()

    return header, row_data


def _rlstrip(data):
    return data.rstrip().lstrip()


def convert_to_vars(header, data):
    tfvars = {}
    for row in data:
        col_data = []
        for col in row:
            col_data.append(col)
    
        #[user_name, group, policy] , [user1, admins, admin]  →  {user_name:user1, group:admins, policy:admin}
        row_data_dict = dict(zip(header, col_data))

        # {user_name:user1, group:admins, policy:admin} → {user1 = {user_name:user1, group:admins, policy:admin} }
        tfvars[row_data_dict["name"]] = row_data_dict
    
    return tfvars


def output_json(src_file_name, data):
    dst_file_path = src_file_name.split(".")[0] + ".json"

    with open(dst_file_path, "w") as f:
        json.dump(data, f, ensure_ascii=False, indent=4, sort_keys=True, separators=(',', ': '))


def main():
    # env_name = sys.argv[1]
    
    # ユーザ情報が記載されたCSVファイルからデータ読み込み
    # csv_path = "../{}/users.csv".format(env_name)
    csv_path = "users.csv"
    header, users_data = load_csv(csv_path)

    # CSVから読み込んだデータをterraformのvariableに代入できる形式に変換
    tfvars = convert_to_vars(header, users_data)

    # tfvarsの形式をjsonファイルとして出力
    output_json(csv_path, tfvars)

if __name__ == "__main__":
    main()
