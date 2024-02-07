# Create a OIDC-trusted connection scoped to my GitHub repository


resource "aws_iam_openid_connect_provider" "github_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.oidc_thumbprint] # Replace this with the actual thumbprint
  url             = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_actions_role" {
  name = "GitHubActionsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc.arn
        }
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:sub" = "repo:YOUR_GITHUB_ORG/YOUR_REPO:ref:refs/heads/YOUR_BRANCH"
          }
        }
      },
    ]
  })
}
