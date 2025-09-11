resource "aws_db_subnet_group" "db" {
  name       = "${var.project}-db-subnets"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

resource "aws_db_instance" "db" {
  identifier               = "${var.project}-db"
  engine                   = "postgres"
  engine_version           = "16"                      # free-tier compatible
  instance_class           = "db.t3.micro"            # free-tier
  allocated_storage        = 20
  db_name                  = var.db_name
  username                 = var.db_username
  password                 = var.db_password
  multi_az                 = false                    # keep costs minimal
  storage_encrypted        = true
  backup_retention_period  = 1
  delete_automated_backups = true
  skip_final_snapshot      = true
  vpc_security_group_ids   = [aws_security_group.db.id]
  db_subnet_group_name     = aws_db_subnet_group.db.name
  publicly_accessible      = false
}