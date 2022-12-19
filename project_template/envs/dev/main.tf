/*
作成するリソースを指定するファイル
moduleを呼び出してリソースを作成する
*/

# module　呼び出し例
module xxx {
    # moduleの場所を指定
    source = "../../modules/sample_module"

    # 環境固有の変数を渡す
    env_params = var.env_params

    # moduleに渡す変数を指定
    <module側の変数名> = <main.tfと同階層で定義されている変数>
}


# デバッグ用にoutputを定義
output debug{
    value = {
        # <変数名> = <module側で定義されているoutput名>
        created_resouce = module.xxx.OutputName
    }
}




