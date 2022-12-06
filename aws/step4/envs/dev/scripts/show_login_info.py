import json
import subprocess
import base64
import csv

def read_file():
    file_path = "terraform.tfstate"
    with open(file_path, "r") as f:
        json_data = json.load(f)
    
    return json_data

def get_login_info(json_data):
    login_info = json_data["outputs"]["passwords"]["value"]
    return login_info
    

def decrypt(cipher_text):
    # 一時的に暗号文をテキストファイルに書き出し
    with open("scripts/tmp.txt", 'w')as f:
        f.write(cipher_text)

    # tfstateから取得したデータをデコード
    command = 'certutil -decode -f scripts/tmp.txt scripts/decoded_tmp.txt'
    subprocess.run(command, stdout=subprocess.PIPE, shell=True)

    # デコードしたファイルの中身を復号化
    command = 'keybase pgp decrypt -S "is0356xi" -i scripts/decoded_tmp.txt'
    result = subprocess.run(command, stdout=subprocess.PIPE, shell=True)
    passwd = result.stdout

    return passwd

def write_file(data):
    with open("login_info.csv", "w") as f:
        writer = csv.writer(f)
        for key, value in data.items():
            writer.writerow([key, value])
        


def main():
    # tfstateからデータを読み込み
    json_data = read_file()

    # tfstateから読み込んデータの中から、ログイン情報を取得
    login_info = get_login_info(json_data)
    print(login_info)

    for user_name, cipher_text in login_info.items():
        # データの復号化
        passwd = decrypt(cipher_text).decode()
        print(passwd, cipher_text)

        # 復号化したパスワードをログイン情報に格納
        login_info[user_name] = passwd


    # ログイン情報をファイルに書き出し
    write_file(login_info)

if __name__ == "__main__":
    main()
