variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "ap-southeast-2"
}

#Network
variable "public_subnet_1_cidr" {
  description = "CIDR block for the first public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for the second public subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_3_cidr" {
  description = "CIDR block for the third private subnet."
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_4_cidr" {
  description = "CIDR block for the fourth private subnet."
  type        = string
  default     = "10.0.4.0/24"
}

variable "availability_zones" {
  description = "List of availability zones to use for subnets."
  type        = list(string)
  default     = ["ap-southeast-2b", "ap-southeast-2c"]
}

#Project
variable "project_name" {
  description = "The name of project"
  type        = string
  default     = "django-app"
}

#RDS
variable "rds_db_name" {
  description = "The name of the RDS database."
  type        = string
  default     = "mydb"
}

variable "rds_username" {
  description = "The username for the RDS database."
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "The password for the RDS database."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "The instance class for the RDS database."
  type        = string
  default     = "db.t3.micro"
}

# ECS
variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "production"
}
