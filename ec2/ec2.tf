locals {
  servers = {
    server-00 = {
      instance_type = var.linux_instance_type
      subnet_id     = aws_subnet.public_us_east_1a.id
    }
    server-01 = {
      instance_type = var.linux_instance_type
      subnet_id     = aws_subnet.public_us_east_1b.id
    }
  }
}

# Create EC2 Instances
resource "aws_instance" "linux-server" {
  for_each = local.servers

  ami                         = data.aws_ami.ubuntu_20_ami.id
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = [aws_security_group.aws-linux-sg.id]
  associate_public_ip_address = var.linux_associate_public_ip_address
  source_dest_check           = false
  #   key_name                    = aws_key_pair.key_pair.key_name
  user_data = file("scripts/aws-user-data.sh")

  # root disk
  root_block_device {
    volume_size           = var.linux_root_volume_size
    volume_type           = var.linux_root_volume_type
    delete_on_termination = true
    encrypted             = false
  }

  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-linux-server"
    Environment = var.app_environment
  }
}

# Define the security group for the Linux server
resource "aws_security_group" "aws-linux-sg" {
  name        = "${lower(var.app_name)}-${var.app_environment}-linux-sg"
  description = "Allow incoming HTTP connections"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
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
