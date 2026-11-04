terraform {
  backend "s3" {
    bucket       = "khan-harness-ai-terraform-state-2026"
    key          = "dev/ec2-secure/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
