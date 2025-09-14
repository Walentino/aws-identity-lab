# Verification – Least-Privilege Policy

After attaching the least‑privilege policy to the principal, verify it:

1. Use the IAM Policy Simulator to test expected operations:

   ```sh
   aws iam simulate-principal-policy \
     --policy-source-arn <principal-arn> \
     --action-names ec2:DescribeInstances s3:ListBucket \
     --resource-arns arn:aws:ec2:REGION:ACCOUNT:instance/* arn:aws:s3:::BUCKET_NAME
   ```

   Confirm that required actions return a decision of "allowed" and other actions not present in the policy return "implicitDeny" or "explicitDeny".

2. Assume the role or use the user credentials and run AWS CLI commands representing typical tasks. Verify permitted actions succeed and actions outside the policy fail.

3. Check CloudTrail logs after applying the policy for any `AccessDenied` events. If legitimate actions are denied, refine the policy accordingly.
