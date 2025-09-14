# Terraform code for delegated admin with permissions boundary

resource "aws_iam_policy" "delegated_boundary" {
  name   = "DelegatedAdminBoundary"
  policy = file("${path.module}/boundary.json")
}

resource "aws_iam_role" "delegated_admin" {
  name                 = "DelegatedAdminRole"
  assume_role_policy   = data.aws_iam_policy_document.delegated_assume.json
  permissions_boundary = aws_iam_policy.delegated_boundary.arn
}

resource "aws_iam_role_policy" "delegated_admin_permissions" {
  name   = "DelegatedAdminPermissions"
  role   = aws_iam_role.delegated_admin.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:CreateRole",
          "iam:PutRolePolicy",
          "iam:AttachRolePolicy",
          "iam:CreateUser",
          "iam:CreatePolicy"
        ],
        Resource = "*"
      }
    ]
  })
}
