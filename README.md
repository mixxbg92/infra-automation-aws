# 🚀 Infrastructure Automation Challenge - AWS Web Stack

## 📌 Overview
This project provisions a basic web application stack on AWS using Terraform.  
It includes:
- A VPC with public and private subnets
- An Application Load Balancer (ALB)
- Auto Scaling Group (ASG) of EC2 web servers (running Nginx)
- RDS MySQL database in private subnets
- Security groups to restrict traffic appropriately

All infrastructure is managed using Infrastructure-as-Code (IaC) principles.

---

## ⚙️ Prerequisites
- AWS account with IAM user/role that has admin or sufficient privileges
- Terraform installed locally (>= v1.3)
- Git installed
- SSH key pair (optional if you need direct EC2 access)

---

## 🚀 Deployment Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/mixxbg92/infra-automation-aws.git
   cd infra-automation-aws/infra
   ```

2. Configure AWS credentials (using aws-cli, env vars, or profiles):
   ```bash
   aws configure
   ```

3. Update variables in `terraform.tfvars` (copy from `terraform.tfvars.example`).

4. Initialize Terraform:
   ```bash
   terraform init
   ```

5. Preview resources:
   ```bash
   terraform plan
   ```

6. Apply configuration:
   ```bash
   terraform apply -auto-approve
   ```

7. After deployment, grab the ALB DNS from outputs or AWS console and open it in a browser.

---

## 🗑️ Cleanup
To destroy all resources and avoid AWS charges:
```bash
terraform destroy -auto-approve
```

---

## 📂 Repository Structure
```
infra-automation-aws/
├── infra/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── userdata.sh
│   ├── terraform.tfvars.example
│   └── terraform.tfvars (ignored)
├── README.md
└── README.pdf
```

---

## ✅ Features
- ALB distributes traffic across EC2 instances in multiple AZs  
- Auto Scaling Group ensures high availability and scaling  
- RDS MySQL runs in private subnets for security  
- UserData boots EC2 instances with Nginx and test HTML page  
- Modular and reproducible setup using Terraform  

---

## 📖 Failover Handling
- If one EC2 instance fails, the ASG replaces it automatically.  
- ALB health checks route traffic only to healthy instances.  
- RDS is single-AZ (for demo). Can be extended to Multi-AZ for production.  
