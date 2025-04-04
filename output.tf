output "oidc" {
  value = aws_iam_openid_connect_provider.github_oidc.arn
}

output "role_arn" {
  value = aws_iam_role.github_actions_role.arn
}
