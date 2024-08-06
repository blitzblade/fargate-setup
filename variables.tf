variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_1" {
    description = "Availability Zone 1"
    type = string
    default = "us-east-1a"
}

variable "az_2" {
  description = "Availability Zone 2"
  type = string
  default = "us-east-1b"
}

variable "db_username" {
    description = "postgres username"
    type = string
    default = "postgres"
}

variable "db_name" {
    description = "postgres db name"
    type = string
    default = "trading_db"
}

variable "db_password" {
    description = "postgres password"
    type = string
    default = "p05tgr3s"
}

variable "es_username" {
    description = "elasticsearch username"
    type = string
    default = "master-user"
  
}

variable "es_password" {
    description = "elasticsearch password"
    type = string
    default = "SuperSecretPassword003!"
  
}

variable "key_name" {
    description = "key name"
    type = string
    default = "ec2ecsglog"
  
}

variable "region" {
    description = "default region"
    type = string
    default = "us-east-1"
}

variable "rabbitmq_username" {
    description = "rabbitmq username"
    type = string
    default = "guest"
}

variable "rabbitmq_password" {
    description = "rabbitmq password"
    type = string
    default = "guest"
}


### internal ip addresses
variable "db_host" {
    description = "postgres db host"
    type = string
    default = "10.0.2.65"
}

variable "rabbitmq_host" {
    description = "Rabbitmq server"
    type = string
    default = "10.0.1.45"
  
}

variable "redis_host" {
    description = "Redis server"
    type = string
    default = "10.0.2.65"
  
}

variable "elasticsearch_host" {
    description = "Elastic search server"
    type = string
    default = "10.0.2.65:9200"
  
}

variable "redis_port" {
    description = "Redis port"
    type = string
    default = "6379"
  
}

# variable "aws_access_key" {
#     description = "The IAM public access key"
# }

# variable "aws_secret_key" {
#     description = "IAM secret access key"
# }

# variable "aws_region" {
#     description = "The AWS region things are created in"
# }

variable "ec2_task_execution_role_name" {
    description = "ECS task execution role name"
    default = "myEcsTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
    description = "ECS auto scale role name"
    default = "myEcsAutoScaleRole"
}

variable "az_count" {
    description = "Number of AZs to cover in a given region"
    default = "2"
}

variable "app_image" {
    description = "Docker image to run in the ECS cluster"
    default = "bradfordhamilton/crystal_blockchain:latest"
}

variable "app_port" {
    description = "Port exposed by the docker image to redirect traffic to"
    default = 8081

}

variable "app_count" {
    description = "Number of docker containers to run"
    default = 3
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
    description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
    default = 512
}

variable "fargate_memory" {
    description = "Fargate instance memory to provision (in MiB)"
    default = 1024
}