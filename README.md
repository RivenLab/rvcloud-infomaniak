# Prerequisites

* terraform
* openstack
* nova cli

## 1 Installation
##### Install OpenStack CLI
```bash
pipx install python-openstackclient
```
##### Install Nova CLI
```bash
pipx install python-novaclient
```

## 2 Load environment variables
Download the openrc file from the horizon interface. Place it in the load_env directory.

Source openrc.sh file
```bash
source load_env/openrc.sh
```

Create s3-env.sh file and add the following content:
```bash
#!/usr/bin/env bash

export AWS_ACCESS_KEY_ID="<AWS_ACCESS_KEY_ID>"
export AWS_SECRET_ACCESS_KEY="<AWS_SECRET_ACCESS_KEY>"
export AWS_DEFAULT_REGION="<AWS_DEFAULT_REGION>"
export AWS_ENDPOINT_URL_S3="<S3_ENDPOINT_URL>"
```
Then source it
```bash
source load_env/s3-env.sh
```

## 3 Run Terraform commands
### Terraform commands
##### 1. Init
```bash
terraform init
```

##### 2. Plan
```bash
terraform plan
```

##### 3. Apply
```bash
terraform apply -auto-approve
```

##### 4. Output
```bash
terraform output
```

##### 5. To Destroy
```bash
terraform destroy -auto-approve
```

## 4 Retrieve OPNsense/Winddows password
To retrieve opnsense or windows root password use this command:
```bash
python3 scripts/get_instance_password.py
```
select the instance name from the list then enter the private ssh key path. The script will output the password.
