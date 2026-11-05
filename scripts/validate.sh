#!/bin/bash
set -euo pipefail

echo "========================================"
echo "Terraform + Checkov + Ollama AI Review"
echo "========================================"

export PATH="$HOME/.local/bin:$PATH"
export AWS_DEFAULT_REGION="ap-south-1"
export AWS_REGION="ap-south-1"
export TF_INPUT=false
export ENFORCE_AI_DECISION=false

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN AWS_PROFILE AWS_EC2_METADATA_DISABLED

export NO_PROXY="169.254.169.254,localhost,127.0.0.1"
export no_proxy="$NO_PROXY"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

echo "Checking required tools..."

for tool in terraform python3 jq git curl ip; do
    command -v "$tool" >/dev/null 2>&1 || {
        echo "ERROR: $tool is not installed"
        exit 1
    }
done

if ! command -v checkov >/dev/null 2>&1; then
    echo "Installing Checkov..."
    python3 -m pip install --user checkov
    export PATH="$HOME/.local/bin:$PATH"
fi

terraform version
checkov --version
python3 --version

echo "Checking EC2 IAM role..."

TOKEN=$(curl --noproxy '*' -fsS --connect-timeout 5 \
    -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

ROLE_NAME=$(curl --noproxy '*' -fsS \
    -H "X-aws-ec2-metadata-token: $TOKEN" \
    "http://169.254.169.254/latest/meta-data/iam/security-credentials/")

if [ -z "$ROLE_NAME" ]; then
    echo "ERROR: EC2 IAM role not detected"
    exit 1
fi

echo "IAM role detected: $ROLE_NAME"

echo "Checking Ollama connection..."

HOST_GATEWAY=$(ip route | awk '/default/ {print $3; exit}')

if [ -z "$HOST_GATEWAY" ]; then
    echo "ERROR: Host gateway not detected"
    exit 1
fi

export OLLAMA_MODEL="llama3.2:1b"
export OLLAMA_URL="http://${HOST_GATEWAY}:11434/api/generate"

curl --noproxy '*' -fsS --connect-timeout 10 \
    "$OLLAMA_URL" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"${OLLAMA_MODEL}\",\"prompt\":\"Reply only: Ollama OK\",\"stream\":false}" \
    | jq -r '.response'

echo "Checking Terraform configuration..."

cd "$REPO_DIR/terraform/ec2-secure"

terraform fmt -check -recursive
terraform init -input=false
terraform validate

cd "$REPO_DIR"

echo "Running Checkov..."

checkov -d terraform/ec2-secure \
    --check CKV_AWS_24,CKV_AWS_8 \
    -o json > checkov-report.json || true

python3 -m json.tool checkov-report.json >/dev/null

FAILED=$(jq '.summary.failed // 0' checkov-report.json)

echo "Checkov failures: $FAILED"

if [ "$FAILED" -gt 0 ]; then
    echo "ERROR: Checkov security failures found"
    exit 1
fi

echo "Creating Terraform plan..."

cd "$REPO_DIR/terraform/ec2-secure"

terraform plan -out=tfplan -input=false
terraform show -json tfplan > "$REPO_DIR/plan.json"

cd "$REPO_DIR"

echo "Running Ollama AI review..."

python3 scripts/ai_terraform_review_ollama.py

cat reports/ai-review.md

echo "VALIDATION COMPLETED SUCCESSFULLY"
