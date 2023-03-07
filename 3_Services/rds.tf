resource "aws_security_group" "stage-rds-sg" {
  name = "stage-RDS-securitygroup"
  description = "stage-RDS-securitygroup"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress {
    #security_groups = [aws_security_group.stage-jumphost-sg.id]
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0",data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  tags = {
    "Name" = "stage-RDS-securitygroup"
     Environment = "stage"
     Terraform   = "true"
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  name_prefix        = "rds-enhanced-monitoring-"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_policy_document" "rds_enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

#creating subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  subnet_ids = data.terraform_remote_state.vpc.outputs.database_subnets[*]
}

resource "aws_db_parameter_group" "pf-rds-paramgrps" {
  name   = "pf-rds-paramgrps"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "stage_rds" {
  #name="pfv3stagedb"
  identifier = "pfv3stagedb"
  instance_class = "db.t3.medium"
  storage_type = "gp3"
  allocated_storage = "50"
  max_allocated_storage = "100"
  engine_version = "14.4"
  db_name = "pfv3stagedb"
  username = "pfvsdfsdf2frwedasdffgshgfbncdsfbadsfgsfasfmin"
  password = "tpM6ukNcxvxcvfgrrJsdfbxcvasdsdaf9fsdUJDsdfx"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids  = toset(aws_security_group.stage-rds-sg.*.id)
  #project_name = "pfv2-stage"
  engine = "postgres"
  skip_final_snapshot = true
  #final_snapshot_identifier = "DELETE ME" # if skip_final_snapshot=false
  apply_immediately = false
  performance_insights_enabled = true
  monitoring_interval = 30
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn
  #create_monitoring_role  = true
  storage_encrypted = true
  enabled_cloudwatch_logs_exports = ["postgresql"]
  #create_cloudwatch_log_group     = true
  parameter_group_name = aws_db_parameter_group.pf-rds-paramgrps.name
  tags = {
    Project     = "pfv3stage"
    Owner       = "Vertisystem PVT. LTD"
    Description = "RDS for pfv3stage"
  }
}
