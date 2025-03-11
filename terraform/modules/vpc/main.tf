# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr 
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-vpc"
      "kubernetes.io/cluster/${var.environment}-cluster" = "shared"
    }
  )
}

# Create Public Subnets (Web and ALB)
resource "aws_subnet" "web" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.web_subnet_cidr
  availability_zone       = var.az_a
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-web-subnet"
      Type = "Public"
      "kubernetes.io/cluster/${var.environment}-cluster" = "shared"
      "kubernetes.io/role/elb" = "1"
    }
  )
}

resource "aws_subnet" "alb" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.alb_subnet_cidr
  availability_zone       = var.az_b
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-alb-subnet"
      Type = "Public"
      "kubernetes.io/cluster/${var.environment}-cluster" = "shared"
      "kubernetes.io/role/elb" = "1"
    }
  )
}

# Create Private Subnets (API and DB)
resource "aws_subnet" "api" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.api_subnet_cidr
  availability_zone = var.az_a

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-api-subnet"
      Type = "Private"
      "kubernetes.io/cluster/${var.environment}-cluster" = "shared"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

resource "aws_subnet" "db" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_cidr
  availability_zone = var.az_b

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-db-subnet"
      Type = "Private"
      "kubernetes.io/cluster/${var.environment}-cluster" = "shared"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Create Route Table Associations for Public Subnets
resource "aws_route_table_association" "web" {
  subnet_id      = aws_subnet.web.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "alb" {
  subnet_id      = aws_subnet.alb.id
  route_table_id = aws_route_table.public.id
}

# Create Elastic IP
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.web.id  

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "main-nat-gateway"
  }
}

# Create Private Route Table 
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt"
  }
}

# Create Route to NAT Gateway for Private Subnets
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

# Route Table Associations for Private Subnets
resource "aws_route_table_association" "api" {
  subnet_id      = aws_subnet.api.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db" {
  subnet_id      = aws_subnet.db.id
  route_table_id = aws_route_table.private.id
}

# Security Group for Web Traffic
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Security group for web traffic (HTTP, HTTPS, SSH)"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "web-security-group"
    Environment = "production"
  }
}