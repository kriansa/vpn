# Create a VPC for this purpose only
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  # This is required so that EFS volumes can be reached within VPC
  # https://docs.aws.amazon.com/efs/latest/ug/troubleshooting-efs-mounting.html
  enable_dns_hostnames = true

  tags = {
    Name = "VPN"
  }
}

# Create a subnet on first AZ of this region
resource "aws_subnet" "main" {
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 1) // 10.0.1.0/24
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id            = aws_vpc.main.id

  tags = {
    Name = "Public-Inbound-AZ1"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "VPN-Default"
  }
}

# Default route table allows all outbound access to internet gateway
resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "VPN-Default"
  }
}

# Allow all outbound access on default SG
resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPN-Default"
  }
}

resource "aws_security_group" "allow_ssh_from_admin" {
  name        = "AllowSSHFromAdmin"
  description = "Allow inbound SSH traffic from Admin"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.admin_ips
  }
}

resource "aws_security_group" "allow_vpn_traffic_from_internet" {
  name        = "AllowVPNTrafficFromInternet"
  description = "Allow inbound OpenVPN traffic from internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "udp"
    from_port   = 1194
    to_port     = 1194
    cidr_blocks = ["0.0.0.0/0"]
  }
}
