resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
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
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
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
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  db_name                 = "wordpressdb"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  db_subnet_group_name = aws_db_subnet_group.private.name
}

resource "aws_db_subnet_group" "private" {
  name       = "private"
  subnet_ids = [aws_subnet.private.id]
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis-cluster"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
  security_group_ids   = [aws_security_group.allow_http.id]
  subnet_group_name    = aws_elasticache_subnet_group.private.name
}

resource "aws_elasticache_subnet_group" "private" {
  name       = "private"
  subnet_ids = [aws_subnet.private.id]
}

output "wordpress_ip" {
  value = aws_instance.wordpress.public_ip
}

output "mysql_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}