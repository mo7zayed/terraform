locals {
  servers = {
    ec2-00 = {
      instance_type = var.linux_instance_type
      subnet_id     = aws_subnet.public_us_east_1a.id
    }
  }
}

# Define the security group for the Linux server
resource "aws_security_group" "ec2-sg" {
  name        = "${lower(var.app_name)}-${var.app_environment}-linux-sg"
  description = "Allow incoming HTTP & SSH connections"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming SSH connections"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-linux-sg"
    Environment = var.app_environment
  }
}

# Create EC2 Instances
resource "aws_instance" "ec2-servers" {
  for_each = local.servers

  ami                         = data.aws_ami.ubuntu-latest-ami.id
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2-sg.id]
  associate_public_ip_address = var.linux_associate_public_ip_address
  source_dest_check           = false
  #   key_name                    = aws_key_pair.key_pair.key_name
  key_name  = "mo7zayed-root-us-east-1"
  user_data = file("scripts/bookstack.sh")

  # root disk
  root_block_device {
    volume_size           = var.linux_root_volume_size
    volume_type           = var.linux_root_volume_type
    delete_on_termination = true
    encrypted             = false
  }

  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-ec2-server"
    Environment = var.app_environment
  }
}
