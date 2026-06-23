# ==============================================================================
# 1. AWS BASELINE: Multi-Account Management & Security Core
# ==============================================================================
resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
}

# Dedicated security operations containment account
resource "aws_organizations_account" "security_core" {
  name      = "security-operations-prod"
  email     = "cloud-security-admin@yourcompany.com"
  parent_id = aws_organizations_organization.org.roots[0].id
}

# AWS Landing Zone Networking Baseline
resource "aws_vpc" "aws_hub_vpc" {
  cidr_block           = "10.100.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "universal-lz-aws-hub" }
}

# ==============================================================================
# 2. AZURE BASELINE: Enterprise Scale Management & Guardrails
# ==============================================================================
# Establishes governance hierarchy boundaries
resource "azurerm_management_group" "enterprise_root" {
  display_name = "Universal-LZ-Root"
}

resource "azurerm_resource_group" "network_hub" {
  name     = "lz-connectivity-hub-rg"
  location = var.azure_location
}

# Azure Landing Zone Networking Hub
resource "azurerm_virtual_network" "azure_hub_vnet" {
  name                = "universal-lz-azure-hub"
  location            = azurerm_resource_group.network_hub.location
  resource_group_name = azurerm_resource_group.network_hub.name
  address_space       = ["10.200.0.0/16"]
}

# ==============================================================================
# 3. GCP BASELINE: Resource Organization Hierarchy
# ==============================================================================
# Baseline landing folder under organization root node
resource "google_folder" "production_environment" {
  display_name = "lz-production-enviroment"
  parent       = "organizations/${var.gcp_org_id}"
}

# Isolated networking core project under the landing zone folder
resource "google_project" "gcp_network_host" {
  name       = "lz-shared-vpc-host"
  project_id = "lz-shared-vpc-host-prod"
  folder_id  = google_folder.production_environment.id
}

# GCP Shared VPC Foundation
resource "google_compute_shared_vpc_host_project" "shared_vpc" {
  project = google_project.gcp_network_host.project_id
}
