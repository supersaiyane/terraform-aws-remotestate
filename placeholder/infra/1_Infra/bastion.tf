######################################################################
# EC2 Security groups
######################################################################

# Security Group for Public Bastion Host
module "public_bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.5.0"

  name = "${local.name}-public-bastion-sg"
  description = "Security Group with SSH port open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id = module.vpc.vpc_id
  # Ingress Rules & CIDR Blocks
  ingress_rules = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  # Egress Rule - all-all open
  egress_rules = ["all-all"]
  tags = local.common_tags
}

#################################################################
# Key-Pair Generation
#################################################################

# resource "tls_private_key" "ssh" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "ssh" {
#   key_name = "StagejumpHost"
#   public_key = tls_private_key.ssh.public_key_openssh
# }

# resource "local_file" "public_ssh_key" {
#   filename = "${path.module}/keys/StagejumpHost-pub.pem"
#   content = tls_private_key.ssh.public_key_openssh
# }

# resource "local_file" "private_ssh_key" {
#   filename = "${path.module}/keys/StagejumpHost.pem"
#   content = tls_private_key.ssh.private_key_pem
# }

######################################################################
# Ec2 Module
######################################################################

# Bastion Host - EC2 Instance that will be created in VPC Public Subnet
module "ec2_public" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.3.0"
  # insert the required variables here
  name                   = "${local.name}-BastionHost"
  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = var.instance_type
  key_name               = "StagejumpHost"
  monitoring             = true
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]
  tags = local.common_tags
  # depends_on = [
  #   aws_key_pair.ssh
  # ]
  
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
    sudo chown -R ec2-user:ec2-user www/
    sudo echo "<html><body><p>Pfv3 Infrastructure is up and ready!<br>
          This infrastructure will have the following components<br>
          1. VPC<br>
          1.1 Subnets<br>
          1.1.1 Private Subents<br>
          1.1.2 Public Subnets<br>
          1.1.3 Database Subnets<br>
          1.2 Internet Gateway<br>
          1.3 Nat Gateway<br>
          1.4 Security Groups<br>
          1.5 Bastion Ec2 <--- I am in front of you :D !!<br>
          2. Services<br>
          2.1 MSK<br>
          2.2 RDS<br>
          2.3 S3<br>
          2.3 ECR</p></body></html>" > /var/www/html/index.html
    EOF
}

######################################################################
# Ec2 Eip
######################################################################

# Create Elastic IP for Bastion Host
# Resource - depends_on Meta-Argument
resource "aws_eip" "bastion_eip" {
  depends_on = [ module.ec2_public, module.vpc ]
  instance = module.ec2_public.id
  vpc      = true
  tags = local.common_tags
}

######################################################################
# Ec2 Provisioners
######################################################################

# Create a Null Resource and Provisioners
resource "null_resource" "copy_ec2_keys" {
  depends_on = [module.ec2_public]
  # Connection Block for Provisioners to connect to EC2 Instance
  connection {
    type     = "ssh"
    host     = aws_eip.bastion_eip.public_ip    
    user     = "ec2-user"
    password = ""
    private_key = file("keys/StagejumpHost.pem")
    #private_key = tls_private_key.ssh.private_key_pem
  }  

## File Provisioner: Copies the terraform-key.pem file to /tmp/terraform-key.pem
  provisioner "file" {
    source      = "keys/StagejumpHost.pem"
    destination = "/tmp/StagejumpHost.pem"
  }
## Remote Exec Provisioner: Using remote-exec provisioner fix the private key permissions on Bastion Host
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /tmp/StagejumpHost.pem"
    ]
  }
## Local Exec Provisioner:  local-exec provisioner (Creation-Time Provisioner - Triggered during Create Resource)
  provisioner "local-exec" {
    command = "echo VPC created on `date` and VPC ID: ${module.vpc.vpc_id} >> creation-time-vpc-id.txt"
    working_dir = "local-exec-output-files/"
    #on_failure = continue
  }

}