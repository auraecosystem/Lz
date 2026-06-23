package main

# Test 1: Verify that a compliant plan (with a proper TTL tag) passes
test_allow_with_valid_ttl {
    mock_input := {"resource_changes": [{
        "address": "aws_s3_bucket.good_bucket",
        "type": "aws_s3_bucket",
        "change": {
            "actions": ["create"],
            "after": {
                "tags": {"ttl_days": "14"},
                "server_side_encryption_configuration": [{"rule": []}]
            }
        }
    }]}
    allow with input as mock_input
}

# Test 2: Verify that an unencrypted S3 bucket is caught and denied
test_deny_unencrypted_s3 {
    mock_input := {"resource_changes": [{
        "address": "aws_s3_bucket.bad_bucket",
        "type": "aws_s3_bucket",
        "change": {
            "actions": ["create"],
            "after": {
                "tags": {"ttl_days": "14"}
                # Missing encryption block
            }
        }
    }]}
    count(deny) > 0 with input as mock_input
}
