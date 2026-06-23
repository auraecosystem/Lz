package main

# 1. Pipeline Control Logic
default allow = false

deny[msg] {
    # Gathers any message produced by our sub-rules
    violations[msg]
}

allow {
    # If the violations set is completely empty, allow the build
    count(violations) == 0
}

# ==============================================================================
# 2. UNIVERSAL POLICY: Enforce TTL (Time-to-Live) Tags on All Resources
# ==============================================================================
# This ensures every resource has a 'ttl_days' tag so environments clean themselves up.
violations[msg] {
    resource := input.resource_changes[_]
    # Only check resources being created or modified
    valid_actions := ["create", "update"]
    valid_actions[_] == resource.change.actions[_]
    
    # Extract tags across different cloud schemas
    tags := get_tags(resource)
    
    # Violation rule: Fail if 'ttl_days' missing, or if it's set longer than 30 days
    not tags.ttl_days
    msg := sprintf("❌ COMPLIANCE FAILURE: Resource '%v' is missing the mandatory 'ttl_days' tag/label.", [resource.address])
}

violations[msg] {
    resource := input.resource_changes[_]
    tags := get_tags(resource)
    
    # Ensure TTL value is an integer and does not exceed corporate limits (e.g., 30 days)
    to_number(tags.ttl_days) > 30
    msg := sprintf("❌ COMPLIANCE FAILURE: Resource '%v' has a 'ttl_days' value of (%v), which exceeds the maximum limit of 30 days.", [resource.address, tags.ttl_days])
}

# Helper rule to parse metadata tag blocks regardless of cloud provider syntax
get_tags(res) = tags {
    # AWS tag schema
    tags := res.change.after.tags
} else = tags {
    # Azure tag schema
    tags := res.change.after.tags
} else = tags {
    # GCP label schema
    tags := res.change.after.labels
} else = tags {
    # Fallback if no tags exist at all
    tags := {}
}

# ==============================================================================
# 3. AWS SECURITY POLICY: Block Public S3 Buckets
# ==============================================================================
violations[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    
    # Check if a developer explicitly set these overrides to false
    resource.change.after.block_public_acls == false
    msg := sprintf("❌ CRITICAL AWS VIOLATION: Bucket policy '%v' must set 'block_public_acls' to true.", [resource.name])
}

# ==============================================================================
# 4. AZURE SECURITY POLICY: Require Private Networks for Databases
# ==============================================================================
violations[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_postgresql_server"
    
    # Fail if public access is enabled
    resource.change.after.public_network_access_enabled == true
    msg := sprintf("❌ CRITICAL AZURE VIOLATION: PostgreSQL Server '%v' cannot be exposed to the public internet.", [resource.name])
}

# ==============================================================================
# 5. GCP SECURITY POLICY: Block Legacy Default Network
# ==============================================================================
violations[msg] {
    resource := input.resource_changes[_]
    resource.type == "google_compute_instance"
    
    # Fail if the network interface points to the standard 'default' VPC
    resource.change.after.network_interface[_].network == "default"
    msg := sprintf("❌ CRITICAL GCP VIOLATION: VM '%v' is using the 'default' VPC network. Custom subnets are required.", [resource.name])
}
