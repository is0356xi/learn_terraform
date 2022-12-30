# IAMユーザを作成
resource "aws_iam_user" "user" {
  for_each = var.user_params

  name = each.value.name
  path = "/${each.value.group}/"
}

# ログイン情報を作成
resource "aws_iam_user_login_profile" "login_profile" {
  for_each = aws_iam_user.user

  user = each.value.name

  # 作成されるパスワードを暗号化
  pgp_key = "keybase:${var.keybase_user}"

  # パスワードのリセットを必須にする
  password_reset_required = true

  depends_on = [aws_iam_user.user]
}


# IAMグループを作成
resource "aws_iam_group" "group" {
  for_each = var.group_params

  name = each.value.name
  path = each.value.path

  depends_on = [aws_iam_user.user]
}

# グループにアタッチする組み込みポリシーを取得
data "aws_iam_policy" "builtin" {
  for_each = var.group_params

  name = each.value.policy_name
}

# グループにポリシーをアタッチ
resource "aws_iam_group_policy" "group_policy" {
  for_each = var.group_params

  name  = each.value.policy_name
  group = aws_iam_group.group[each.value.name].id

  # 組み込みポリシーをアタッチする
  policy = data.aws_iam_policy.builtin[each.key].policy
}

# グループにユーザを追加
resource "aws_iam_group_membership" "membership" {
  for_each = var.user_params

  # メンバーシップの名前
  name = each.value.group

  # 追加するユーザ名のリスト
  users = [
    each.value.name
  ]

  # 追加先のグループID
  group = aws_iam_group.group[each.value.group].id
}



/*
カスタムポリシーがある場合、ユーザにカスタムポリシーをアタッチする

１．カスタムポリシーがnull以外のユーザを取得
２. カスタムポリシーを作成
３. 作成したカスタムポリシーをユーザにアタッチ

*/

# １．カスタムポリシーがnull以外のユーザを取得
locals {
  # custom_policyがnullではないユーザオブジェクトを取得し、nameをキーとした辞書型にする
  custom_policy_user = { for key, value in var.user_params : key => value if value.custom_policy != "null" }
}


# ２. カスタムポリシーを作成
resource "aws_iam_policy" "policy" {
  for_each = local.custom_policy_user # local.custom_policy_userの各キーがresourceブロックのキーとなる。 user1 = {policyオブジェクト}

  name   = each.value.custom_policy
  policy = file("${var.env_params.module_path}/IAM/policy/${each.value.custom_policy}.json")
}

# ３. 作成したカスタムポリシーをユーザにアタッチ
resource "aws_iam_user_policy_attachment" "attach" {
  for_each = local.custom_policy_user

  user       = aws_iam_user.user[each.value.name].name
  policy_arn = aws_iam_policy.policy[each.value.name].arn

  depends_on = [aws_iam_policy.policy]
}


# アクセスキーの作成
# resource "aws_iam_access_key" "access_key" {
#   for_each = aws_iam_user.user

#   user    = each.value.name
#   pgp_key = "keybase:${var.keybase_user}"

#   depends_on = [aws_iam_user.user]
# }