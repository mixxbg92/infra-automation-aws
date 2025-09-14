# 🚀 Infrastructure Automation on AWS with Terraform

This repository provisions a **basic, production-style web stack** on **AWS** using **Terraform**:

- **Application Load Balancer (ALB)**
- **Auto Scaling Group (EC2, Nginx via user data)**
- **RDS MySQL** in private subnets
- **VPC, subnets, routing, security groups**
- **S3 remote state + DynamoDB locking** (optional, recommended)

It’s designed for a **live demo**: you’ll deploy, hit the ALB URL, and show **failover** by replacing an instance while traffic continues to flow.

---

## 🧱 Architecture (at a glance)

```
Internet
   │
ALB (public subnets)
   │
Target Group
   │
ASG of EC2 (Nginx via user data)
   │
DB SG allows MySQL from Web SG
   │
RDS MySQL (private subnets)
```

- **High-level**: ALB → EC2 (Auto Scaling) → RDS
- **Networking**: VPC with 2x public + 2x private subnets across AZs
- **Security**: 
  - ALB SG: allow HTTP from the Internet
  - Web SG: allow HTTP **only** from ALB SG
  - DB SG: allow MySQL **only** from Web SG

---

## ✅ Prerequisites

- **AWS account** + an IAM user with rights to create VPC/EC2/ALB/RDS/DynamoDB/S3
- **Terraform** ≥ 1.5 installed
- **AWS CLI** configured locally (`aws configure`)
- (Optional) **GitHub repo** for CI/CD (you already have one)

---

## 📦 Repo Structure

```
infra-automation-aws/
├── infra/
│   ├── main.tf            # Core resources (VPC, ALB, ASG, RDS, SGs)
│   ├── variables.tf       # Inputs
│   ├── outputs.tf         # Useful outputs (ALB DNS, RDS endpoint, ASG name)
│   ├── userdata.sh        # Nginx + instance metadata page (uses IMDSv2)
│   ├── providers.tf       # Providers + (optional) S3 backend
│   └── terraform.tfvars   # Your values (gitignored)
└── .github/workflows/terraform.yml  # Optional CI/CD
```

---

## ⚙️ Configuration

Create `infra/terraform.tfvars` with values like:

```hcl
aws_region     = "eu-central-1"
project_name   = "iac-web-stack"

vpc_cidr       = "10.0.0.0/16"
public_subnets = ["10.0.1.0/24","10.0.2.0/24"]
private_subnets= ["10.0.11.0/24","10.0.12.0/24"]

instance_type  = "t3.micro"
asg_min        = 2
asg_desired    = 2
asg_max        = 4

db_name                 = "appdb"
db_username             = "appuser"
db_password             = "ChangeMe123!"
db_instance_class       = "db.t3.micro"
db_allocated_storage    = 20

# If you permit SSH, set your IP; otherwise keep locked or remove the rule
ssh_cidr = "0.0.0.0/32"
```

> 🔒 **Tip:** Never commit real passwords. Use environment variables or CI/CD secrets if automating.

### Optional: Remote State (S3 + DynamoDB)

In `providers.tf` you can define an S3 backend (recommended for teams):

```hcl
terraform {
  backend "s3" {
    bucket         = "your-unique-tf-state-bucket"
    key            = "infra/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

Create them once via AWS CLI:

```bash
aws s3api create-bucket --bucket your-unique-tf-state-bucket \
  --region eu-central-1 \
  --create-bucket-configuration LocationConstraint=eu-central-1
aws s3api put-bucket-versioning --bucket your-unique-tf-state-bucket \
  --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

Then re-init:
```bash
terraform init -reconfigure
```

---

## 🚀 Deploy

From the `infra` folder:

```bash
terraform init          # installs providers & (optional) sets up backend
terraform validate
terraform apply -auto-approve
```

When it finishes, note the outputs, especially:

```
alb_dns_name = iac-web-stack-alb-xxxx.eu-central-1.elb.amazonaws.com
```

Open that URL in your browser — you should see an Nginx page showing **Instance ID** and **AZ**.

---

## 🔁 Change Rollout (Auto Instance Refresh)

When you edit `userdata.sh` (or the Launch Template), the **ASG automatically rolls instances** thanks to `instance_refresh`.  
To test:
1. Change the page text in `userdata.sh` (e.g., add “(v2)”).
2. Run `terraform apply -auto-approve`.
3. Watch **EC2 → Auto Scaling Groups → Instance refresh**. Instances will roll gradually.
4. Refresh the ALB URL to see the updated page.

> Under the hood, the Launch Template uses a `timestamp()` in `templatefile(...)` so Terraform always produces a new version, triggering the refresh.

---

## 🧪 Failover Demo (Live)

1. Open the **ALB DNS** in your browser.
2. In AWS Console → **EC2 → Auto Scaling Groups**, pick an instance and **Terminate** it.
3. The page continues working (ALB shifts traffic).
4. ASG **launches a replacement** automatically; after it passes health checks, it starts serving traffic.

This demonstrates **self-healing** + **no-downtime maintenance**.

---

## 🧹 Teardown

```bash
terraform destroy -auto-approve
```

> If VPC deletion seems “stuck”, check for leftover **ENIs**, **subnets**, or **gateways** still attached (often from RDS) and remove them, then rerun destroy.

---

## 🛠️ Troubleshooting

- **Page shows empty Instance/AZ** → Ensure `userdata.sh` uses **IMDSv2**:
  ```bash
  TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
  INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s \
    http://169.254.169.254/latest/meta-data/instance-id)
  AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s \
    http://169.254.169.254/latest/meta-data/placement/availability-zone)
  ```

- **User data changed but instances didn’t** → ASG instance refresh will handle it automatically; otherwise start an **Instance Refresh** from the ASG console.

- **Duplicate security group name** → Use `name_prefix` for SGs or delete/import the conflicting SG. Names must be unique per VPC.

- **Destroy stuck on VPC** → Delete any ENIs/IGWs/subnets/route tables still associated, then rerun `terraform destroy`.

---

## 📋 Design Choices (short)

- **Terraform** for transparent, repeatable IaC.
- **ALB + ASG** for a realistic, resilient web tier.
- **RDS (managed)** to separate stateful DB from stateless web tier.
- **IMDSv2** for metadata access on Amazon Linux 2023.
- **Instance Refresh** for safe rolling updates on any template change.

---

## 🔐 CI/CD (Optional)

Add GitHub Actions secrets in **Settings → Secrets and variables → Actions**:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION` (e.g., `eu-central-1`)

A workflow can then run `terraform fmt/validate/plan/apply` on pushes or PRs.

---

## 🙌 Demo Flow (what to say/show)

1. Show repo structure (Terraform code + user data).
2. `terraform apply` → point out resources being created.
3. Open the **ALB URL** → page shows instance metadata.
4. **Terminate one EC2** → traffic keeps flowing; ASG replaces it.
5. (Optional) Show RDS running in private subnets.
6. `terraform destroy` to clean up.
