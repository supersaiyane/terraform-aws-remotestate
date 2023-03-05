######################################################################
# Ec2 Ami
######################################################################

# Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"
    values = [ "amzn2-ami-hvm-*-gp2" ]
  }
  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }
}

######################################################################
# eks
######################################################################

data "aws_iam_policy_document" "pfv3stage-PolicyELBPermissions"{
  
  statement {
      sid = "1"

      actions = [
          "elasticloadbalancing:Describe*",
      ]

      resources = [
        "*"
      ]
    }
  
  
  statement {
    sid = "2"

    actions = [
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeInternetGateways"
    ]

    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "pfv3stage-PolicyCloudWatchMetrics"{
  statement {
    sid = "1"

    actions = [
      "cloudwatch:PutMetricData"
    ]

    resources = [
      "*"
    ]
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks_cluster.id
}


######################################################################
# OIDC
######################################################################


# Datasource: AWS Partition
# Use this data source to lookup information about the current AWS partition in which Terraform is working
data "aws_partition" "current" {}

######################################################################
# vpc
######################################################################

# AWS Availability Zones Datasource
data "aws_availability_zones" "available" {
}