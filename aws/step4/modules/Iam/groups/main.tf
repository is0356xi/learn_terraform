resource "aws_iam_group" "group" {

for_each = var.group_params
  name = each.value.name
  path = each.value.path
}

# グループにポリシーをアタッチ
resource aws_iam_group_policy group_policy{
    for_each = var.group_params

    name = "${each.value.name}_policy"
    group = aws_iam_group.group[each.value.name].id

    # mainから見た時の相対ファイルパス
    policy = file("../../modules/Iam/policy/${each.value.policy}.json")
}


# グループにユーザを追加
resource aws_iam_group_membership membership{
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


