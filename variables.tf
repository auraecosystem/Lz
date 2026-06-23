variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Primary target region for AWS deployment workloads."
}

variable "azure_location" {
  type        = string
  default     = "East US"
  description = "Target data centre region for Azure Base platforms."
}

variable "gcp_org_id" {
  type        = string
  description = "The target Google Cloud Organization Node numeric identity."
}

variable "gcp_project_id" {
  type        = string
  description = "Target project ID used for operational metadata configurations."
}

variable "gcp_region" {
  type        = string
  default     = "us-central1"
  description = "Default computing region for GCP workloads."
}
