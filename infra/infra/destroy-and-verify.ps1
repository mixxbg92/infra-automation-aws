# ===========================
#  Terraform Destroy + Verify
# ===========================

# Step 1: Destroy everything Terraform created
Write-Host 'Running terraform destroy...' -ForegroundColor Red
terraform destroy -auto-approve -var='db_password=StrongPassword123!'

# Step 2: Verify cleanup in AWS
Write-Host "`nVerifying AWS resources in eu-central-1..." -ForegroundColor Green

# EC2 instances
Write-Host "`n--- EC2 Instances ---"
aws ec2 describe-instances --region eu-central-1 --output table

# Load Balancers
Write-Host "`n--- Load Balancers ---"
aws elbv2 describe-load-balancers --region eu-central-1 --output table

# Target Groups
Write-Host "`n--- Target Groups ---"
aws elbv2 describe-target-groups --region eu-central-1 --output table

# RDS Databases
Write-Host "`n--- RDS Databases ---"
aws rds describe-db-instances --region eu-central-1 --output table

# Auto Scaling Groups
Write-Host "`n--- Auto Scaling Groups ---"
aws autoscaling describe-auto-scaling-groups --region eu-central-1 --output table

# VPCs
Write-Host "`n--- VPCs ---"
aws ec2 describe-vpcs --region eu-central-1 --output table

# Final message
Write-Host 'Done! Only default resources should remain (those cost $0).' -ForegroundColor Cyan
