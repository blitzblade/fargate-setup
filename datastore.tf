
# PostgreSQL (Amazon RDS)
resource "aws_db_instance" "postgres" {
  identifier     = "postgres-db"
  engine         = "postgres"
  engine_version = "14"
  #   parameter_group_name    = aws_db_parameter_group.postgresql.name
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true
  publicly_accessible = true
  storage_encrypted   = true

  # VPC and subnet group configurations
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = aws_subnet.public.*.id
}

resource "aws_security_group" "db_sg" {
  name   = "db_sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

# RabbitMQ (EC2 instance with EBS volume)
resource "aws_instance" "rabbitmq" {
  ami                    = "ami-04a81a99f5ec58529" # Ubuntu Server 20.04 LTS AMI ID
  instance_type          = "t2.micro"
  key_name               = var.key_name # Replace with your actual key pair name
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.rabbitmq_sg.id]
  user_data              = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y erlang
              echo "deb https://packages.erlang-solutions.com/ubuntu focal contrib" | sudo tee /etc/apt/sources.list.d/erlang.list
              wget -O- https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | sudo apt-key add -
              sudo apt-get update
              sudo apt-get install -y rabbitmq-server
              sudo systemctl enable rabbitmq-server
              sudo systemctl start rabbitmq-server
              sudo rabbitmq-plugins enable rabbitmq_management
              sudo systemctl restart rabbitmq-server
              EOF

  tags = {
    Name = "rabbitmq-server"
  }
}


resource "aws_security_group" "rabbitmq_sg" {
  name        = "rabbitmq_sg"
  description = "Allow SSH and RabbitMQ traffic"
  vpc_id      = aws_vpc.main.id # Replace with your actual VPC ID

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 15672
    to_port     = 15672
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


# Redis (Amazon ElastiCache)
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis-cluster"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name

  security_group_ids = [aws_security_group.redis_sg.id]
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = aws_subnet.private.*.id
}

resource "aws_security_group" "redis_sg" {
  name   = "redis-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Elasticsearch (Amazon OpenSearch Service)
resource "aws_opensearch_domain" "elasticsearch" {
  domain_name    = "es-domain"
  engine_version = "Elasticsearch_7.1"

  cluster_config {
    instance_type  = "t3.small.search"
    instance_count = 2
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp2"
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.es_username
      master_user_password = var.es_password
    }
  }

  access_policies = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : "es:*",
        "Resource" : "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/es-domain/*"
      }
    ]
  })

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }
}

# # Network Configuration
# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
# }

# resource "aws_subnet" "subnet1" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.1.0/24"
#   availability_zone = "us-east-1a"
# }

# resource "aws_subnet" "subnet2" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.2.0/24"
#   availability_zone = "us-east-1b"
# }

