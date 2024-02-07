output "github_oidc_url" {
  value = aws_iam_openid_connect_provider.github_oidc.url
}

output "role_arn" {
  value = aws_iam_role.github_actions_role.arn
}
