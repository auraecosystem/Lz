terraform {
  required_version = ">= 1.6.0"
  
  # Choose the backend provider that matches your primary governance anchor:
  
  # Option A: AWS S3 Backend with DynamoDB State Locking
  backend "s3" {
    bucket         = "aura-lz-global-tfstate"
    key            = "prod/universal-landing-zone.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "aura-lz-tflocks" # Prevents concurrent pipeline collisions
  }

  # Option B: HashiCorp Terraform Cloud (Agility Alternative)
  # backend "remote" {
  #   organization = "auraecosystem"
  #   workspaces { name = "lz-production" }
  # }
}
