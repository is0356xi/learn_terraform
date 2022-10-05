# 呼び出し時に渡される引数を定義
variable env {}
variable nic {} # 仮想マシンにアタッチするnicのデータ


/*
    ""で初期化されている変数　　→　環境固有の変数を読み込む
    nullで初期化されている変数　→　依存リソース作成後に格納される
*/


# 仮想マシンのパラメータ
variable vm_params{
    default = {
        vm1 = {
            name = "winvm1"
            computer_name = "vm1"
            rg_name = ""
            location = ""
            admin_name = "testadmin1"
            admin_password = "TestAdmin1!"
            size = "Standard_A1_v2"
            network_interface_ids = null

            os_disk = {
                type = "Standard_LRS"
                cach = "ReadWrite"
            }

            image = {
                publisher = "MicrosoftWindowsServer"
                offer     = "WindowsServer"
                sku       = "2016-Datacenter"
                version   = "latest"
            }
        },

        vm2 = {
            name = "winvm2"
            computer_name = "vm2"
            rg_name = ""
            location = ""
            admin_name = "testadmin2"
            admin_password = "TestAdmin12"
            size = "Standard_A1_v2"
            network_interface_ids = null

            os_disk = {
                type = "Standard_LRS"
                cach = "ReadWrite"
            }

            image = {
                publisher = "MicrosoftWindowsServer"
                offer     = "WindowsServer"
                sku       = "2016-Datacenter"
                version   = "latest"
            }
        }

    }
}