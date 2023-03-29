resource "aws_security_group" "redis_cluster_sg" {
  name = "redis_cluster-sg"
  description = "redis_cluster-securitygroup"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
  "Name" =   "redis_cluster-sg"
  Project     = "pfv3stage"
  Owner       = "Vertisystem PVT. LTD"
  Description = "ElastiCache-Redis for pfv3stage"
  }
}

# Define the subnet group for the ElastiCache Redis cluster
resource "aws_elasticache_subnet_group" "redis_cluster" {
  name       = "redis-cluster-subnet-group"
  #subnet_ids = flatten([aws_subnet.private_subnets.*.id])
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets[*]

  tags = {
  Project     = "pfv3stage"
  Owner       = "Vertisystem PVT. LTD"
  Description = "ElastiCache-Redis for pfv3stage"
  }
}

resource "aws_cloudwatch_log_group" "pfv3stageECRedis-LG" {
  name = "pfv3stageECRedis_logs"
}


resource "aws_elasticache_replication_group" "redis_cluster" {
  replication_group_id           = "redis-cluster"
  description                    = "ElastiCache Redis cluster"
  engine                         = "redis"
  engine_version                 = "6.x"
  parameter_group_name           = "default.redis6.x.cluster.on"
  node_type                      = "cache.t2.medium"
  port                           = 6379
  automatic_failover_enabled     = true
  #number_cache_clusters          = 3
  snapshot_window                = "04:00-05:00"
  snapshot_retention_limit       = 7
  transit_encryption_enabled     = true
  at_rest_encryption_enabled     = true
  multi_az_enabled               = true
  replicas_per_node_group = 1
  num_node_groups         = 2
  subnet_group_name = aws_elasticache_subnet_group.redis_cluster.name
  security_group_ids = [aws_security_group.redis_cluster_sg.id]

    log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.pfv3stageECRedis-LG.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }

  tags = {
  Project     = "pfv3stage"
  Owner       = "Vertisystem PVT. LTD"
  Description = "ElastiCache-Redis for pfv3stage"
  }
}