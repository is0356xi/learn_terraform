import csv
import sys
import os
import json

def load_data(path):
    data = []
    with open(path, 'r') as f:
        rows = csv.reader(f, delimiter=",")
        header = next(rows)
        header = [column.strip() for column in header]
        for row in rows:
            data.append(row)
        f.close()

    return header, data

def convert_to_tfvars(key_list, data):
    tfvars = {}
    # 各行のデータを取り出し
    for row in data:
        row_data = []
        # 列のデータを取り出してリストに追加
        for column in row:
            row_data.append(column.strip())

        # {列名:列データ}に変換
        dict_data = dict(zip(key_list, row_data))

        tfvars[dict_data["display_name"]] = dict_data

    return tfvars

def output_json(data, path):
    output_file = path.split(".")[0] + ".json"

    with open(output_file, 'w') as f:
        json.dump(data, f)
        f.close()


def main(path):
    header, data = load_data(path)
    tfvars_data = convert_to_tfvars(header,data)
    output_json(tfvars_data, path)

if __name__ == "__main__":
    # ユーザ情報が記載されたCSVファイル名
    file_name = sys.argv[1]
    path = os.path.join("", file_name)

    main(path)