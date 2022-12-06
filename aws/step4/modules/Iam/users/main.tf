locals {
  version = "v1"
}

resource "aws_iam_user" "user" {
  for_each = var.user_params

  # name = each.value.name
  name = "${local.version}_${each.value.name}"
  path = "/${each.value.group}/"
}

resource "aws_iam_user_login_profile" "login_profile" {
  for_each = aws_iam_user.user

  user    = each.value.name
  pgp_key = "keybase:is0356xi"

  depends_on = [aws_iam_user.user]
}

resource "aws_iam_access_key" "access_key" {
  for_each = aws_iam_user.user

  user    = each.value.name
  pgp_key = "keybase:is0356xi"

  depends_on = [aws_iam_user.user]
}
