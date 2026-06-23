``'
universal-landing-zone/
├── .github/
│   └── workflows/
│       └── tf-deploy.yml          # Master GitOps pipeline (Installs tools, runs OPA, applies code)
│
├── policies/
│   └── landing_zone.rego          # Master Rego Policy file (Enforces TTL tags, blocks public access)
│
├── modules/                       # Reusable baseline infrastructure blocks
│   ├── networking/                # Multi-cloud VPC and Subnet blueprints
│   ├── identity/                  # Permissions and IAM security
│   └── security/                  # Cloud logging and auditing configs
│
├── environments/                  # Live workspace folders where teams deploy resources
│   ├── universal-core-prod/       # Active target workspace
│   │   ├── providers.tf           # Connects to AWS, Azure, and GCP simultaneously
│   │   ├── main.tf                # Deploys your multi-cloud resource baseline 
│   │   └── variables.tf           # Stores configuration parameters (Regions, IDs, etc.)
│   │
│   └── staging/                   # Optional: Staging environment sandbox
│
├── .gitignore                     # Prevents local secrets and tfplan files from entering Git
└── README.md                      # Onboarding guide for teams adopting your landing zone
