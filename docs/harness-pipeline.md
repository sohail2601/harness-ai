# Harness CI/CD Pipeline

## Pipeline Overview

The project uses Harness CI/CD to manage Terraform infrastructure provisioning and cleanup on AWS.

The pipeline integrates:

- GitHub for source code
- Harness for pipeline orchestration and approvals
- AWS IAM Role for AWS authentication
- Terraform for Infrastructure as Code
- Checkov for infrastructure security scanning
- Ollama for AI-assisted Terraform plan review
- Slack for deployment notifications

## Pipeline Execution Flow

```text
GitHub Repository
       |
       v
Harness Pipeline
       |
       v
Hello World
       |
       v
Validate Checkov Plan AI Review
       |
       v
Manual Approval - Terraform Apply
       |
       v
Terraform Apply
       |
       v
Slack Apply Notification
       |
       v
Manual Approval - Terraform Destroy
       |
       v
Terraform Destroy
```

## Pipeline Configuration

**Pipeline name:** `terraform-security-ai-review`

### 1. Hello World

Runs a basic shell command to verify that the pipeline execution environment is working.

### 2. Validate Checkov Plan AI Review

Current implementation:

- Prints a Bash environment test message.
- Displays the Bash version.

**Important:** This step currently performs only a basic shell test. It does not yet invoke `scripts/validate.sh`, Terraform validation, Checkov scanning, or the Ollama AI review.

The repository contains a separate validation script for those operations.

### 3. Approve Terraform Apply

A manual approval step before infrastructure provisioning.

Configuration:

- Approval message: Approve Terraform Apply
- Minimum approvers: 1
- Automatic approval: Disabled
- Automatic rejection: Disabled

### 4. Terraform Apply

The pipeline:

1. Clones the GitHub repository.
2. Initializes Terraform.
3. Checks the Terraform configuration.
4. Creates a Terraform execution plan.
5. Applies the plan.
6. Displays Terraform outputs.

AWS region: `ap-south-1`

AWS authentication uses the EC2 IAM role rather than static AWS access keys.

### 5. Slack Apply Notification

The pipeline invokes:

`scripts/slack-notify.sh`

The script:

- Initializes Terraform.
- Reads the EC2 instance ID.
- Reads the private IP address.
- Reads the security group ID.
- Sends deployment information to Slack using an incoming webhook.

The webhook must be supplied securely through Harness secrets.

### 6. Approve Terraform Destroy

A manual approval step before infrastructure deletion.

Configuration:

- Approval message: Approve Terraform Destroy
- Minimum approvers: 1
- Automatic approval: Disabled
- Automatic rejection: Disabled

### 7. Terraform Destroy

The pipeline invokes:

`scripts/destroy.sh`

The script:

1. Clones the GitHub repository.
2. Initializes the S3 Terraform backend.
3. Checks the Terraform state.
4. Creates a Terraform destroy plan.
5. Applies the destroy plan.
6. Checks the state after destruction.

## Supporting Project Scripts

| Script | Responsibility |
|---|---|
| `scripts/validate.sh` | Terraform validation, Checkov scanning, plan generation, and AI review |
| `scripts/ai_terraform_review_ollama.py` | Analyzes Terraform plan and Checkov results using Ollama |
| `scripts/slack-notify.sh` | Sends Terraform deployment information to Slack |
| `scripts/destroy.sh` | Destroys infrastructure using Terraform |

## External Dependencies

The pipeline depends on:

- A configured Harness account and execution environment.
- A GitHub repository accessible to the Harness execution environment.
- An AWS EC2 IAM role with appropriate permissions.
- An existing S3 Terraform state bucket.
- Terraform CLI.
- Git and other required command-line utilities.
- A reachable Ollama service and configured model for AI review.
- A Slack incoming webhook stored securely in Harness.

## Important Implementation Notes

- The current validation pipeline step is a Bash test and does not execute the full validation script.
- The AI review script is separate from the current pipeline execution flow.
- AI review is advisory by default. Its enforcement setting is controlled by `ENFORCE_AI_DECISION`.
- Terraform Apply and Terraform Destroy have separate manual approval steps.
- Terraform state must be preserved in the configured S3 backend.
- Credentials, webhook URLs, and access tokens must never be committed to GitHub.

## Pipeline Safety

Terraform Apply and Destroy can create or delete AWS resources.

Manual approval is included before both operations. Review the Terraform plan and expected infrastructure changes before approving an execution.
