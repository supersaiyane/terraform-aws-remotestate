resource "aws_security_group" "pfv3stageMSK-sg" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  name        = "pfv3stageMSK-sg"
  description = "Security group for pfv3stageMSK"

  # ingress_cidr_blocks = module.vpc.cidr_block
  # ingress_rules       = ["kafka-broker-tcp", "kafka-broker-tls-tcp"]

  #possible ports 
  # "kafka-broker-tcp",
  # "kafka-broker-tls-tcp",
  # "kafka-broker-tls-public-tcp",
  # "kafka-broker-sasl-scram-tcp",
  # "kafka-broker-sasl-scram-tcp",
  # "kafka-broker-sasl-iam-tcp",
  # "kafka-broker-sasl-iam-public-tcp",
  # "kafka-jmx-exporter-tcp",
  # "kafka-node-exporter-tcp"
  ingress {
    cidr_blocks = ["10.0.0.0/16"]
    from_port = 9092
    to_port = 9092
    protocol = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  tags = {
    "Name" = "pfv3stageMSK-sg"
     Environment = "stage"
     Terraform   = "true"
  }
}

data "aws_msk_broker_nodes" "pfv3stageMSKnodes" {
  cluster_arn = aws_msk_cluster.pfv3stageMSK.arn
}

resource "aws_cloudwatch_log_group" "pfv3stageMSK-LG" {
  name = "pfv3stagemsk_broker_logs"
}

resource "aws_msk_configuration" "pfv3stageMSK-config" {
  kafka_versions = ["2.7.1"]
  name           = "pfv3stageMSK-config"

  server_properties = <<PROPERTIES
    auto.create.topics.enable = true
    delete.topic.enable = true
    PROPERTIES
}

resource "aws_msk_cluster" "pfv3stageMSK" {
  cluster_name           = "pfv3stageMSK"
  kafka_version          = "2.7.1"
  number_of_broker_nodes = 4 #2X subnets

  #potential issue : https://github.com/hashicorp/terraform-provider-aws/issues/17484
  configuration_info {
    arn = aws_msk_configuration.pfv3stageMSK-config.arn
    revision = aws_msk_configuration.pfv3stageMSK-config.latest_revision
  }
  
    broker_node_group_info {
    instance_type = "kafka.m5.xlarge"
    client_subnets = data.terraform_remote_state.vpc.outputs.private_subnets[*]

    storage_info {
      ebs_storage_info {
        # provisioned_throughput {
        #   enabled           = true
        #   volume_throughput = 250
        # }
        volume_size = 20
      }
    }
    security_groups = [aws_security_group.pfv3stageMSK-sg.id]
  }
    logging_info {
      broker_logs {
        cloudwatch_logs {
          enabled   = true
          log_group = aws_cloudwatch_log_group.pfv3stageMSK-LG.name
        }
        # firehose {
        #   enabled         = true
        #   delivery_stream = aws_kinesis_firehose_delivery_stream.test_stream.name
        # }
        # s3 {
        #   enabled = true
        #   bucket  = aws_s3_bucket.bucket.id
        #   prefix  = "logs/msk-"
        # }
      }
  }

  tags = {
  Project     = "pfv3stage"
  Owner       = "Vertisystem PVT. LTD"
  Description = "MSK for pfv3stage"
  }
}