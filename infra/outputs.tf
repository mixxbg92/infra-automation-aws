output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "Public URL of the load balancer"
}


output "web_asg_name" {
  value       = aws_autoscaling_group.web_asg.name
  description = "Name of the web Auto Scaling Group"
}


output "rds_endpoint" {
  value       = aws_db_instance.db.address
  description = "RDS endpoint"
  sensitive   = true
}