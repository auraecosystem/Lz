tar --lzip -cf codes.lz --exclude='.git' --exclude='codes.lz' .
# Evaluate the master denial array
opa eval --data policies/landing_zone.rego --input tfplan.json "data.main.deny"

# Check if the build passes entirely (Returns true/false)
opa eval --data policies/landing_zone.rego --input tfplan.json "data.main.allow"
