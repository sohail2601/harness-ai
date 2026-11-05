# AWS Infrastructure Configuration

## Project AWS Environment

| Configuration | Value |
|---|---|
| AWS Region | ap-south-1 (Mumbai) |
| Operating System | Amazon Linux 2023 |
| EC2 Instance Type | t3.micro |
| Root Volume | 8 GB |
| EBS Encryption | Enabled |
| Monitoring | Enabled |
| Terraform Backend | Amazon S3 |
| AWS Authentication | IAM Role |

## Terraform Remote State

Terraform uses an S3 backend.

| Setting | Configuration |
|---|---|
| Bucket | khan-harness-ai-terraform-state-2026 |
| Region | ap-south-1 |
| State Key | dev/ec2-secure/terraform.tfstate |
| Encryption | Enabled |
| State Locking | S3 native lockfile |

S3 bucket versioning should also be enabled to support state recovery.

## EC2 Configuration

Terraform provisions an Amazon Linux 2023 EC2 instance.

Configuration:

- Instance type: t3.micro
- Latest matching Amazon Linux 2023 AMI
- Default VPC
- First available subnet returned by the Terraform data source
- Monitoring enabled
- IMDSv2 required
- Encrypted 8 GB root EBS volume

## Security Group

The Terraform security group contains these rules:

| Direction | Protocol | Port | Source / Destination |
|---|---|---|---|
| Inbound | TCP | 22 | 13.233.108.220/32 |
| Outbound | TCP | 443 | 0.0.0.0/0 |

SSH access is restricted to the configured public IP address.

## IAM Authentication

The automation uses an EC2 IAM role for AWS authentication instead of embedding long-lived AWS access keys in pipeline scripts.

The Harness Delegate must have access to the EC2 instance role credentials.

## Terraform Provider

| Setting | Value |
|---|---|
| Provider | hashicorp/aws |
| Provider Version | 5.31.0 |
| Required Terraform Version | >= 1.5.0 |
| Configured Region | ap-south-1 |

## Terraform Outputs

The Terraform configuration exports:

- instance_id
- private_ip
- security_group_id

## Security Notes

- Keep the SSH CIDR restricted to a trusted IP.
- Do not expose the Ollama API publicly.
- Keep the S3 state bucket private.
- Enable S3 versioning and encryption.
- Protect Terraform state because it may contain sensitive infrastructure information.
- Use IAM roles instead of static AWS credentials.
