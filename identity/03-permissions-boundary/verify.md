# Verification – Permissions Boundary

To test your delegated admin setup:

1. Assume the delegated admin role using STS and attempt to create a new IAM role with an AdministratorAccess policy. The `iam:AttachRolePolicy` call should fail because the boundary denies it.
2. Use the IAM Policy Simulator to check a denied action:

   ```sh
   aws iam simulate-principal-policy \
     --policy-source-arn <delegated-admin-role-arn> \
     --action-names iam:DeleteRole \
     --resource-arns "*" \
     --query 'EvaluationResults[].{Action: EvalActionName, Decision: EvalDecision}'
   ```

   The result should show an "explicitDeny".

3. Test allowed actions by launching an EC2 instance or creating an S3 bucket (if those services are allowed in your boundary). They should work as expected.

4. Review CloudTrail logs to confirm that attempts to perform restricted IAM actions generate `AccessDenied` events. Adjust the boundary or delegated policy as necessary.
