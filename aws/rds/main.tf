/// RDS ///

resource "aws_db_subnet_group" "lab" {
  name       = "${var.dbname}-${var.environment}-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.dbname}"
    Environment = var.environment
  }
}

resource "aws_db_instance" "db" {
  identifier                 = "${var.dbname}-${var.environment}"
  allocated_storage          = 20
  storage_type               = "gp3"
  db_name                    = "multi"
  engine                     = "mysql"
  engine_version             = "8.0.39"
  instance_class             = "db.t3.micro"
  username                   = var.dbuser
  password                   = var.dbpassword
  parameter_group_name       = aws_db_parameter_group.mysql.name
  option_group_name          = aws_db_option_group.mysql.name
  skip_final_snapshot        = true
  apply_immediately          = true
  vpc_security_group_ids     = [aws_security_group.db.id]
  db_subnet_group_name       = aws_db_subnet_group.lab.name
  auto_minor_version_upgrade = false
  multi_az                   = true
  tags = {
    Name = "${var.dbname}-${var.environment}"
    Environment = var.environment
  }
}



resource "aws_security_group" "db" {
  name        = "${var.dbname}-${var.environment}-sg"
  description = "Database Group Security Groups"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.dbname}-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_was" {
  security_group_id = aws_security_group.db.id

  cidr_ipv4   = "10.0.0.0/16"
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}

resource "aws_vpc_security_group_egress_rule" "db" {
  security_group_id = aws_security_group.db.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_db_option_group" "mysql" {
  name                     = "${var.dbname}-${var.environment}-option-group"
  option_group_description = "${var.dbname}-${var.environment}-Option Group"
  engine_name              = "mysql"
  major_engine_version     = "8.0"
}

resource "aws_db_parameter_group" "mysql" {
  name   = "${var.dbname}-${var.environment}-parameter-group"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "time_zone"
    value = "Asia/Seoul" 
  }
}