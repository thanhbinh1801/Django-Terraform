resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "main"
  subnet_ids = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
}

resource "aws_db_instance" "rds_instance" {
  identifier              = "production"
  instance_class          = var.db_instance_class
  db_name                 = var.rds_db_name
  username                = var.rds_username
  password                = var.db_password
  port                    = "5432"
  engine                  = "postgres"
  engine_version          = "16"
  allocated_storage       = "20"
  storage_encrypted       = true
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  storage_type            = "gp2"
  publicly_accessible     = false
  backup_retention_period = 7
  skip_final_snapshot     = true
}



