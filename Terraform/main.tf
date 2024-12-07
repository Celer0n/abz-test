provider "aws" {
  region  = var.region
}

provider "vault" {
  address = "http://192.168.0.250:8200"
  token   = "hvs.Fa4wYKgpDNwlGEx1IHBx6k5b"
}

data "vault_generic_secret" "secret_credentials" {
     path = "db_data/secret_tf"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-1b"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "allow_http" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "wordpress" {
  ami           = "ami-0b5673b5f6e8f7fa7"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.allow_http.id]

  tags = {
    Name = "WordPress"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.4.3"
  instance_class       = "db.t2.micro"
  db_name              = "wordpressdb"
  username             = data.vault_generic_secret.secret_credentials.data["username"]
  password             = data.vault_generic_secret.secret_credentials.data["password"]
  parameter_group_name = "default.mysql8.4.3"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  db_subnet_group_name = aws_db_subnet_group.private.name
}

resource "aws_db_subnet_group" "private" {
  name       = "private"
  subnet_ids = [
      aws_subnet.private.id,
      aws_subnet.public.id,
    ]
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis-cluster"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379
  security_group_ids   = [aws_security_group.allow_http.id]
  subnet_group_name    = aws_elasticache_subnet_group.private.name
}

resource "aws_elasticache_subnet_group" "private" {
  name       = "private"
  subnet_ids = [aws_subnet.private.id]
}