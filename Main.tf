# 1. Setup the Universal Backend to track cloud states safely
terraform {
  required_version = ">= 1.5.0"
  backend "remote" {} # Can connect to Terraform Cloud, AWS S3, or Azure Blob
}

# 2. Deploy Safe Network Guardrails
module "global_networking" {
  source   = "../../modules/networking"
  vpc_cidr = "10.0.0.0/16"
  environment = "production"
}

# 3. Deploy Mandatory Security Auditing
module "central_security" {
  source             = "../../modules/security"
  enable_audit_logs  = true
  retention_in_days  = 365
}
