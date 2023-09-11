resource "aws_vpc" "main" {
  cidr_block = "10.101.0.0/16"

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
    Name = "ap-unicorn-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ap-unicorn-public-rt"
  }
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_subnet" "public_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.101.25.64/26"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ap-unicorn-public-a"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.101.25.128/26"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "ap-unicorn-public-b"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.101.25.192/26"
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "ap-unicorn-public-c"
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
    Name = "ap-unicorn-natgw-a"
  }
}

resource "aws_nat_gateway" "private_b" {
  depends_on = [aws_internet_gateway.main]

  allocation_id = aws_eip.private_b.id
  subnet_id = aws_subnet.public_b.id

  tags = {
    Name = "ap-unicorn-natgw-b"
  }
}

resource "aws_nat_gateway" "private_c" {
  depends_on = [aws_internet_gateway.main]

  allocation_id = aws_eip.private_c.id
  subnet_id = aws_subnet.public_c.id

  tags = {
    Name = "ap-unicorn-natgw-c"
  }
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ap-unicorn-private-a-rt"
  }
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ap-unicorn-private-b-rt"
  }
}

resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ap-unicorn-private-c-rt"
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
  cidr_block = "10.101.26.0/26"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "ap-unicorn-private-a"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.101.26.64/26"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "ap-unicorn-private-b"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.101.26.128/26"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "ap-unicorn-private-c"
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
  service_name = "com.amazonaws.ap-northeast-2.s3"
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.ap-northeast-2.dynamodb"
}
