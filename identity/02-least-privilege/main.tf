# Terraform configuration for least privilege policy attachment

resource "aws_iam_policy" "least_privilege" {
  name        = "LeastPrivilegePolicy"
  description = "Least privilege policy generated from Access Analyzer"
  policy      = file("${path.module}/generated-policy.json")
}

resource "aws_iam_role_policy_attachment" "attach_least_privilege" {
  role       = aws_iam_role.developer.name
  policy_arn = aws_iam_policy.least_privilege.arn
}
