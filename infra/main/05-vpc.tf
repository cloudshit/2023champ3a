resource "aws_vpc" "main" {
  cidr_block = "10.100.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "unicorn-main"
  }
}

// --- public

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "us-unicorn-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "us-unicorn-public-rt"
  }
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_subnet" "public_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.100.12.192/26"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "us-unicorn-public-a"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.100.13.0/26"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "us-unicorn-public-b"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.100.13.64/26"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "us-unicorn-public-c"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

// -- private

resource "aws_eip" "private_a" {
}

resource "aws_eip" "private_b" {
}

resource "aws_eip" "private_c" { 
}

resource "aws_nat_gateway" "private_a" {
  depends_on = [aws_internet_gateway.main]

  allocation_id = aws_eip.private_a.id
  subnet_id = aws_subnet.public_a.id

  tags = {
    Name = "us-unicorn-natgw-a"
  }
}

resource "aws_nat_gateway" "private_b" {
  depends_on = [aws_internet_gateway.main]

  allocation_id = aws_eip.private_b.id
  subnet_id = aws_subnet.public_b.id

  tags = {
    Name = "us-unicorn-natgw-b"
  }
}

resource "aws_nat_gateway" "private_c" {
  depends_on = [aws_internet_gateway.main]

  allocation_id = aws_eip.private_c.id
  subnet_id = aws_subnet.public_c.id

  tags = {
    Name = "us-unicorn-natgw-c"
  }
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "us-unicorn-private-a-rt"
  }
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "us-unicorn-private-b-rt"
  }
}

resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "us-unicorn-private-c-rt"
  }
}

resource "aws_route" "private_a" {
  route_table_id = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.private_a.id
}

resource "aws_route" "private_b" {
  route_table_id = aws_route_table.private_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.private_b.id
}

resource "aws_route" "private_c" {
  route_table_id = aws_route_table.private_c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.private_c.id
}

resource "aws_subnet" "private_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.100.13.128/26"
  availability_zone = "us-east-1a"

  tags = {
    Name = "us-unicorn-private-a"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.100.13.192/26"
  availability_zone = "us-east-1b"

  tags = {
    Name = "us-unicorn-private-b"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.100.14.0/26"
  availability_zone = "us-east-1c"

  tags = {
    Name = "us-unicorn-private-c"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_c.id
}

// --- endpoints

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.s3"
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.dynamodb"
}
