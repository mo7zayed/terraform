// Create the VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc"
    Environment = var.app_environment
  }
}

// Create the internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-igw"
    Environment = var.app_environment
  }
}

// Create the subnets
resource "aws_subnet" "public_us_east_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-public-us-east-1a"
    Environment = var.app_environment
  }
}

resource "aws_subnet" "private_us_east_1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.128.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-private-us-east-1a"
    Environment = var.app_environment
  }
}

// Disabled for now, It can be enabled on need
// Create the NAT gateway in each AZ and it's elastic IPs
# resource "aws_eip" "eip_nat_us_east_1a" {
#   tags = {
#     Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-eip-nat-us-east-1a"
#     Environment = var.app_environment
#   }
# }
# resource "aws_nat_gateway" "nat_public_us_east_1a" {
#   allocation_id = aws_eip.eip_nat_us_east_1a.id
#   subnet_id     = aws_subnet.public_us_east_1a.id
#   tags = {
#     Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-nat-public-us-east-1a"
#     Environment = var.app_environment
#   }
#   depends_on = [aws_internet_gateway.igw]
# }
# // Create and Configure route tables
# resource "aws_route_table" "rt_private_us_east_1a" {
#   vpc_id = aws_vpc.vpc.id
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat_public_us_east_1a.id
#   }


#   tags = {
#     Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-rt-private-us-east-1a"
#     Environment = var.app_environment
#   }
# }

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-rt-public"
    Environment = var.app_environment
  }
}

resource "aws_route_table_association" "rta_private_us_east_1a" {
  subnet_id      = aws_subnet.private_us_east_1a.id
  route_table_id = aws_route_table.rt_private_us_east_1a.id
}

resource "aws_route_table_association" "rta_public_us_east_1a" {
  subnet_id      = aws_subnet.public_us_east_1a.id
  route_table_id = aws_route_table.rt_public.id
}
