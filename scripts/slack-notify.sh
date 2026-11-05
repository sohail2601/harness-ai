#!/bin/bash
set -euo pipefail

echo "================================"
echo "Starting Slack Notification"
echo "================================"

export PATH="$HOME/.local/bin:$PATH"
export AWS_DEFAULT_REGION="ap-south-1"
export AWS_REGION="ap-south-1"

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset AWS_PROFILE
unset AWS_EC2_METADATA_DISABLED

if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
    echo "ERROR: SLACK_WEBHOOK_URL environment variable is missing."
    exit 1
fi

if [[ "$SLACK_WEBHOOK_URL" != https://hooks.slack.com/services/* ]]; then
    echo "ERROR: Slack webhook URL format is invalid."
    exit 1
fi

for tool in git terraform jq curl; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "ERROR: $tool is missing"
        exit 1
    fi
done

REPO_URL="https://github.com/sohail2601/harness-ai.git"
WORKDIR="/tmp/terraform-harness-ollama-project-slack"

echo "Cloning repository..."
rm -rf "$WORKDIR"
git clone "$REPO_URL" "$WORKDIR"

cd "$WORKDIR/terraform/ec2-secure"

echo "Initializing Terraform..."
terraform init -input=false

echo "Reading Terraform outputs..."

INSTANCE_ID=$(terraform output -raw instance_id 2>/dev/null || echo "unknown")
PRIVATE_IP=$(terraform output -raw private_ip 2>/dev/null || echo "unknown")
SECURITY_GROUP_ID=$(terraform output -raw security_group_id 2>/dev/null || echo "unknown")

echo "Instance ID: $INSTANCE_ID"
echo "Private IP: $PRIVATE_IP"
echo "Security Group ID: $SECURITY_GROUP_ID"

PAYLOAD=$(jq -n \
    --arg instance "$INSTANCE_ID" \
    --arg ip "$PRIVATE_IP" \
    --arg sg "$SECURITY_GROUP_ID" \
    '{
      text: ("Terraform deployment completed successfully.\nInstance ID: " + $instance + "\nPrivate IP: " + $ip + "\nSecurity Group: " + $sg)
    }')

echo "Sending Slack notification..."

curl --fail --silent --show-error \
    -X POST \
    -H "Content-type: application/json" \
    --data "$PAYLOAD" \
    "$SLACK_WEBHOOK_URL"

echo "Slack notification sent successfully!"
echo "SLACK NOTIFICATION COMPLETED"
