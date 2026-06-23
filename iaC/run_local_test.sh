#!/bin/bash
# Exit immediately if any command fails
set -e

echo "🔍 Step 1: Validating Terraform syntax..."
terraform fmt -check
terraform validate

echo "📦 Step 2: Creating a simulated change plan..."
# This generates a plan file without executing any live changes in the cloud
terraform plan -out=local_test.tfplan

echo "🔄 Step 3: Converting plan data into structured JSON..."
# OPA reads the JSON structure to analyze resource attributes
terraform show -json local_test.tfplan > local_test_plan.json

echo "🛡️ Step 4: Running Open Policy Agent (OPA) Guardrail Scan..."
if [ -d "policies" ]; then
    # Run the evaluation against your .rego policy files
    opa eval --data policies/ --input local_test_plan.json "data.main.deny" > opa_test_results.json
    
    # Extract and count any violation messages found in the results array
    VIOLATIONS=$(jq '.result[0].expressions[0].value | length' opa_test_results.json 2>/dev/null || echo "0")
    
    if [ "$VIOLATIONS" -gt 0 ]; then
        echo "🛑 SCAN FAILED: OPA caught $VIOLATIONS security or compliance violations!"
        jq '.result[0].expressions[0].value' opa_test_results.json
        exit 1
    else
        echo "✅ SCAN PASSED: All resources comply with your landing zone rules!"
    fi
else
    echo "⚠️ Warning: 'policies/' directory not found. Skipping OPA scan step."
fi

echo "🧹 Step 5: Cleaning up temporary test files..."
rm -f local_test.tfplan local_test_plan.json opa_test_results.json
echo "🎉 Local validation check completed successfully!"
