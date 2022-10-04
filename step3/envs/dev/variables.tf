# terraform plan/apply/destroy時に、自動で読み込まれる変数群
variable env{
    default = {
        name = "dev"
    }
}