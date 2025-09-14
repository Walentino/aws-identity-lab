# Verify DeveloperRole

Follow these steps to verify that the `DeveloperRole` is configured correctly.

1. **List the attached policies**:

   ```sh
   aws iam list-attached-role-policies --role-name DeveloperRole
   ```

   Confirm that `PowerUserAccess` (or your chosen policy) is listed.

2. **Assume the role**:

   ```sh
   CREDS=$(aws sts assume-role --role-arn arn:aws:iam::<account-id>:role/DeveloperRole --role-session-name verify-session)
   export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.Credentials.AccessKeyId')
   export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.Credentials.SecretAccessKey')
   export AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.Credentials.SessionToken')
   ```

3. **Check your identity**:

   ```sh
   aws sts get-caller-identity
   ```

   The returned `Arn` should contain `role/DeveloperRole`.

4. **Perform a test action**:

   Try to list S3 buckets or describe EC2 instances to ensure the role has the expected permissions:

   ```sh
   aws s3 ls
   ```

   If the command succeeds, your role assumption process is working.
