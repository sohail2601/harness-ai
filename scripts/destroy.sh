set -e

echo "========================================"
echo "Starting Terraform Destroy"
echo "========================================"

export PATH="$HOME/.local/bin:$PATH"

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset AWS_PROFILE
unset AWS_EC2_METADATA_DISABLED

export AWS_DEFAULT_REGION="ap-south-1"
export AWS_REGION="ap-south-1"
export TF_INPUT=false

REPO_URL="https://github.com/sohail2601/harness-ai.git"
WORKDIR="/tmp/terraform-harness-ollama-project-destroy"

echo "Cloning repository..."
rm -rf "$WORKDIR"
git clone "$REPO_URL" "$WORKDIR"

cd "$WORKDIR/terraform/ec2-secure"

echo "Checking backend configuration..."
if [ ! -f backend.tf ]; then
  echo "ERROR: backend.tf not found."
  exit 1
fi

cat backend.tf

echo "Cleaning Terraform local cache..."
rm -rf .terraform
rm -f tfplan destroy.tfplan

echo "Initializing Terraform backend..."
terraform init -reconfigure -input=false

echo "Checking Terraform state..."
terraform state list > /tmp/terraform-destroy-state.txt

if [ ! -s /tmp/terraform-destroy-state.txt ]; then
  echo "ERROR: No Terraform resources found in state."
  echo "Check backend bucket, key and region."
  exit 1
fi

echo "Resources found in Terraform state:"
cat /tmp/terraform-destroy-state.txt

echo "Creating Terraform destroy plan..."
terraform plan -destroy -out=destroy.tfplan -input=false

echo "Destroy plan created successfully."

echo "Applying Terraform destroy plan..."
terraform apply -input=false destroy.tfplan

echo "Checking state after destroy..."
terraform state list || true

echo "========================================"
echo "TERRAFORM DESTROY COMPLETED"
echo "========================================"
