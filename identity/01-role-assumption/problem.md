# 01 - Creating and assuming a developer IAM role

## Problem

To ensure that you are not always working with administrator credentials, you need to create an IAM role for development in your AWS account and assume it when needed.

## Solution

### 1. Create a trust policy

Define a trust policy that allows a specific IAM user (or group) to assume the role. For example, to allow the IAM user `Alice` from account `123456789012` to assume the role:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "AWS": "arn:aws:iam::123456789012:user/Alice" },
    "Action": "sts:AssumeRole"
  }]
}
```

Save this JSON as `trust-policy.json`.

### 2. Create the role and attach a permissions policy

Create the role with the trust policy and attach a managed policy that grants the permissions your developers need. The AWS CLI commands below create a role called `DeveloperRole` and attach the AWS managed `PowerUserAccess` policy:

```sh
aws iam create-role \
  --role-name DeveloperRole \
  --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy \
  --role-name DeveloperRole \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

These commands correspond to AWS IAM CLI examples that show how to create a role and attach a policy【854151067034376†L249-L263】.

### 3. Assume the role

Assume the role to obtain temporary credentials. Use `aws sts assume-role` specifying the role ARN and a session name:

```sh
CREDS=$(aws sts assume-role \
    --role-arn arn:aws:iam::123456789012:role/DeveloperRole \
    --role-session-name dev-session)

export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.Credentials.SessionToken')
```

The `assume-role` command returns temporary security credentials【854151067034376†L319-L326】. Export them as environment variables or configure them in a named profile.

### 4. Verify

- List the role’s attached policies to confirm the correct permissions:

  ```sh
  aws iam list-attached-role-policies --role-name DeveloperRole
  ```

- Check your caller identity after assuming the role to verify that you are operating as the role:

  ```sh
  aws sts get-caller-identity
  ```

- Perform a simple AWS operation (e.g., `aws s3 ls`) to ensure the role works as expected.

### Terraform equivalent

You can automate this configuration in Terraform:

```hcl
resource "aws_iam_role" "developer_role" {
  name = "DeveloperRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::123456789012:user/Alice"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "developer_poweruser" {
  role       = aws_iam_role.developer_role.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
```

Apply this configuration with `terraform apply` to create the role and attach the policy automatically.

## Why this works and trade‑offs

Assuming a role instead of using long‑lived administrator credentials reduces the blast radius of accidental changes and enforces least privilege. Temporary session credentials expire automatically, limiting the window for misuse【854151067034376†L319-L326】. However, you must refresh credentials periodically and ensure that the attached policies grant sufficient permissions for your development tasks without being overly broad.
