# Repository Structure

This document provides a detailed breakdown of the repository organization.

## Directory Layout

```
azure-terraform-foundation/
├── .github/workflows/         # CI/CD pipeline definitions
│   └── terraform.yml          # Main Terraform workflow
├── backend-configs/           # Terraform backend configurations
│   ├── dev.hcl                # Development backend config
│   └── prod.hcl               # Production backend config
├── environments/              # Environment-specific configurations
│   ├── dev/                   # Development environment
│   │   ├── main.tf            # Main Terraform configuration
│   │   ├── variables.tf       # Variable definitions
│   │   ├── outputs.tf         # Output definitions
│   │   └── terraform.tfvars   # Variable values
│   └── prod/                  # Production environment
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars
├── modules/                   # Reusable Terraform modules
│   └── resource-group/        # Resource group module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
├── docs/                      # Documentation
│   ├── repository-structure.md
│   ├── configuration.md
│   ├── setup-guide.md
│   └── commands-reference.md
├── .gitignore                # Git ignore rules
├── .terraformignore          # Terraform ignore rules
└── README.md                 # Project overview
```

## Key Directories

### `.github/workflows/`
Contains GitHub Actions workflow definitions for automated CI/CD.

- **terraform.yml**: Main workflow for terraform plan (on PRs) and apply (on main branch)

### `backend-configs/`
Terraform backend configuration files for remote state management.

- **dev.hcl**: Development environment backend settings
- **prod.hcl**: Production environment backend settings

### `environments/`
Environment-specific Terraform configurations.

Each environment directory contains:
- **main.tf**: Core infrastructure definition
- **variables.tf**: Input variable declarations
- **outputs.tf**: Output value definitions
- **terraform.tfvars**: Variable values specific to the environment

### `modules/`
Reusable Terraform modules following best practices.

Each module includes:
- **main.tf**: Module resources
- **variables.tf**: Module inputs
- **outputs.tf**: Module outputs
- **README.md**: Module documentation

### `docs/`
Comprehensive project documentation.

## Design Principles

### Separation of Concerns
- Environments are isolated with dedicated configurations
- Modules are self-contained and reusable
- Backend state is managed separately per environment

### DRY (Don't Repeat Yourself)
- Common resources defined in modules
- Environment-specific values in `.tfvars` files
- Shared workflow logic in CI/CD pipeline

### Security
- No hardcoded credentials
- Remote state with locking
- Environment-specific access controls

### Scalability
- Easy to add new environments
- Modular architecture supports growth
- Clear structure for team collaboration
