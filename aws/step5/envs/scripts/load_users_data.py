import csv
import sys

def load_csv(csv_path):
    data = []
    with open(csv_path, 'r') as f:
        rows = csv.reader(f)
        # ヘッダーをスキップ
        header = next(rows)
        for row in rows:
            data.append(row)
        f.close()

    return data

def convert_to_vars(data):
    vars = {}
    for row in data:
        key = row[0]
        group = row[1]
        policy = row[2]

        vars[key] = {
            "name" : key,
            "group" : group,
            "policy" : policy
        } 
    
    return vars

def main():
    env_name = sys.argv[1]
    
    # ユーザ情報が記載されたCSVファイルからデータ読み込み
    csv_path = "../{}/users.csv".format(env_name)
    users_data = load_csv(csv_path)

    # CSVから読み込んだデータをterraformのvariableに代入できる形式に変換
    vars = convert_to_vars(users_data)

    # terraform applyにパイプするために標準出力
    print(vars)

if __name__ == "__main__":
    main()
