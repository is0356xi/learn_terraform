output "created_iam_user" {
  value = [for user in aws_iam_user.user : user.name]
}

output "encrypted_password" {
  value = [for key in aws_iam_user_login_profile.login_profile : key.encrypted_password]
}

output "encrypted_secret" {
  value = [for key in aws_iam_access_key.access_key : key.encrypted_secret]
}