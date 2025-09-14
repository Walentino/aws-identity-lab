# Delegating IAM Administration with a Permissions Boundary

## Problem

You need to delegate creation of IAM roles and users to a trusted team without giving them unrestricted power. The team should only be able to assign permissions up to a defined limit.

## Solution

Use a permissions boundary—a managed policy that defines the maximum permissions any IAM principal can get. Create a boundary policy denying sensitive actions and allowing typical development actions, then assign it to the delegated admin role.

Steps:

1. Write a boundary policy JSON with an `ExplicitDeny` on sensitive IAM and Organizations actions and an `Allow` statement for safe services such as EC2, S3, Lambda, CloudWatch and logs.
2. Create the boundary policy using the AWS CLI:
   ```sh
   aws iam create-policy --policy-name DelegatedAdminBoundary --policy-document file://boundary.json
   ```
3. Create a delegated admin role that users in your organization can assume. Specify the boundary using `--permissions-boundary <boundary-arn>` (CLI) or the `permissions_boundary` argument in Terraform.
4. Attach a policy to the delegated admin role granting `iam:CreateRole`, `iam:PutRolePolicy`, `iam:AttachRolePolicy`, and any other necessary permissions to create and manage roles, but not those denied in the boundary.

### Terraform example

```
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
```

## Why this works & trade-offs

A permissions boundary is a guardrail: the effective permissions of any principal are the intersection of its attached policies and the boundary. Even if the delegated admin tries to attach AdministratorAccess, the boundary will prevent actions not allowed by the boundary. However, boundaries don’t grant permissions themselves; you still need to attach the appropriate policies. Make sure the boundary is comprehensive—too restrictive and your delegates may not do their job; too permissive and you defeat the purpose.

## Verification

- Assume the delegated admin role and create a test role with the boundary attached. Attempt to attach an AdministratorAccess policy; it should fail.
- Use `aws iam simulate-principal-policy --policy-source-arn <delegated-admin-role-arn> --action-names iam:DeleteRole` to confirm the action is denied.
- Try to perform allowed actions such as creating an EC2 instance or S3 bucket; they should succeed.
