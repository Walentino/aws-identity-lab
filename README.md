# AWS Identity Lab

This repository is a collection of self-contained recipes for implementing best-practice identity and access management (IAM) patterns on AWS.

Each recipe includes:

- A clear problem statement.
- Step-by-step solution instructions with Terraform modules and, where appropriate, AWS CLI commands.
- A short explanation of why the solution works and trade‑offs to consider.
- Verification or test steps.

The lab is inspired by the book *Implementing Identity Management on AWS* and focuses on practical tasks that build a secure, scalable IAM foundation. The first set of recipes covers:

1. **Creating and assuming a development role** instead of using long‑lived administrator credentials.
2. **Generating least‑privilege policies** based on actual CloudTrail usage and refining them.
3. **Delegating IAM administration with permissions boundaries** so that teams can create roles without elevating privileges.

Additional recipes and improvements will be added over time. Feel free to fork, contribute, and open issues.
