locals {
  servers = {
    ec2-00 = {
      instance_type = var.linux_instance_type
      subnet_id     = aws_subnet.private_us_east_1a.id
    }
    ec2-01 = {
      instance_type = var.linux_instance_type
      subnet_id     = aws_subnet.private_us_east_1b.id
    }
  }
}

# Define the security group for the Linux server
resource "aws_security_group" "ec2_sg" {
  name        = "${lower(var.app_name)}-${var.app_environment}-linux-sg"
  description = "Allow incoming HTTP connections from ALB"
  vpc_id      = aws_vpc.vpc.id

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

resource "aws_security_group_rule" "alb_ec2_traffic" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

# Create EC2 Instances
resource "aws_instance" "ec2-servers" {
  for_each = local.servers

  ami                         = data.aws_ami.ubuntu-latest-ami.id
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = false
  source_dest_check           = false
  #   key_name                    = "mo7zayed-root-us-east-1"
  user_data = file("scripts/aws-user-data.sh")

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
