
locals {
  url = "https://token.actions.githubusercontent.com"
}

data "tls_certificate" "tls" {
  url = local.url
}

# 1️⃣ Create the OIDC Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = local.url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.tls.certificates[*].sha1_fingerprint
}

# 2️⃣ Create the IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions_role" {
  name = "GitHubActionsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "${var.repository_paths}"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.github_oidc.arn}"
        }
      }
    ]
  })
}

# 3️⃣ Attach IAM Policy to the Role
resource "aws_iam_role_policy_attachment" "admin_access" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.github_actions_role.name
}