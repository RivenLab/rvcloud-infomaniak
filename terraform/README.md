# Prerequisites

* terraform

## Load environment variables
Download the openrc file from the horizon interface. Place it in the load_env directory.

Source openrc.sh file
```bash
source load_env/openrc.sh
```

Login to terraform cloud for state management
```bash
terraform login
```

## Copy and edit tfvars file
```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
