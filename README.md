# AI-Powered Infrastructure Automation with Terraform and Harness

## Project Overview

This project automates AWS infrastructure provisioning using Terraform and Harness CI/CD.

It combines infrastructure validation, security scanning, AI-assisted risk analysis, manual approval, and automated deployment.

## Technology Stack

- AWS EC2
- AWS IAM
- Amazon S3
- Terraform
- Harness CI/CD
- Docker
- GitHub
- Checkov
- Python
- Ollama
- Llama 3.2 1B
- Slack

## Pipeline Workflow

1. Developer pushes code to GitHub.
2. Harness starts the pipeline.
3. Docker Delegate executes pipeline tasks.
4. Terraform formatting and validation run.
5. Checkov scans Terraform configuration.
6. Terraform generates an execution plan.
7. Python converts the plan into JSON.
8. Ollama reviews infrastructure changes.
9. Harness waits for manual approval.
10. Terraform Apply provisions AWS resources.
11. Slack receives a deployment notification.

## Architecture

Developer -> GitHub -> Harness Pipeline -> Docker Delegate -> Terraform Validation -> Checkov Scan -> Terraform Plan -> Ollama AI Review -> Manual Approval -> Terraform Apply -> AWS

## Security Practices

- Use an EC2 IAM role for AWS authentication.
- Store Terraform state in an encrypted S3 backend.
- Restrict SSH access to trusted IP addresses.
- Use IMDSv2.
- Store secrets securely in Harness.
- Never commit tokens, passwords, access keys, or webhook URLs.
- Do not expose Ollama port 11434 publicly.
- Review Terraform plans before applying changes.

## Repository Structure

```text
harness-ai/
├── scripts/
│   ├── ai_terraform_review_ollama.py
│   ├── validate.sh
│   ├── destroy.sh
│   └── slack-notify.sh
├── terraform/
│   └── ec2-secure/
│       ├── backend.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── provider.tf
│       └── variables.tf
├── .gitignore
└── README.md

## Important

AI recommendations are advisory and do not replace security controls or human approval.

Terraform Destroy can permanently delete managed AWS resources. Always inspect the destroy plan before execution.

## Project Goal

Build -> Validate -> Scan -> Plan -> Review -> Approve -> Deploy -> Monitor
