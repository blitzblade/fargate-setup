# resource "aws_ecs_task_definition" "core_api_task" {
#  family             = "trading-services-user"
#  network_mode       = "awsvpc"
#  requires_compatibilities = [ "FARGATE" ]
#  execution_role_arn = aws_iam_role.ecs_instance_role.arn
#  cpu                = 256
#  runtime_platform {
#    operating_system_family = "LINUX"
#    cpu_architecture        = "X86_64"
#  }
#  container_definitions = jsonencode([
#    {
#      name      = "core-api"
#      image     = "docker.io/kwesidadson/core-api:latest"
#      cpu       = var.fargate_cpu
#      memory    = var.fargate_memory
#      essential = true
#      portMappings = [
#        {
#          containerPort = 8080
#          hostPort      = 8080
#          protocol      = "tcp"
#        }
#      ]
#      logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           "awslogs-group"         = "/ecs/core-api-service"
#           "awslogs-region"        = var.region
#           "awslogs-stream-prefix" = "ecs"
#         }
#       }
#      environment = [
#         {
#           name  = "SPRING_DATASOURCE_HOST"
#           value = var.db_host
#         },
#         {
#           name  = "SPRING_DATASOURCE_USERNAME"
#           value = var.db_username
#         },
#         {
#           name  = "SPRING_DATASOURCE_PASSWORD"
#           value = var.db_password
#         },
#          {
#           name  = "SPRING_DATASOURCE_DATABASE"
#           value = var.db_name
#         },
#         {
#           name  = "SPRING_RABBITMQ_HOST"
#           value = var.rabbitmq_host
#         },
#         {
#           name  = "SPRING_RABBITMQ_USER"
#           value = var.rabbitmq_username
#         },
#         {
#           name  = "SPRING_RABBITMQ_PASSWORD"
#           value = var.rabbitmq_password
#         },
#         {
#           name  = "ELASTICSEARCH_URL"
#           value = var.elasticsearch_host
#         },
#         {
#           name  = "ELASTICSEARCH_MASTER_USERNAME"
#           value = var.es_username
#         },
#         {
#           name  = "ELASTICSEARCH_MASTER_PASSWORD"
#           value = var.es_password
#         },
#          {
#           name  = "REDIS_HOST"
#           value = var.redis_host
#         },
#         {
#           name  = "REDIS_PORT"
#           value = var.redis_port
#         }
#       ]
#    }
#  ])
# }

# resource "aws_ecs_service" "core_api_service" {
#  name            = "core-api"
#  cluster         = aws_ecs_cluster.main.id
#  task_definition = aws_ecs_task_definition.core_api_task.arn
#  desired_count   = var.app_count
#  launch_type = "FARGATE"

#  network_configuration {
#    subnets         = [aws_subnet.subnet2.id]
#    security_groups = [aws_security_group.ecs_tasks.id]
#    assign_public_ip = true
#  }

#  load_balancer {
#    target_group_arn = aws_lb_target_group.app.id
#    container_name   = "core-api"
#    container_port   = 8080
#  }

#  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs-ecs_task_execution_policy_attachment]
# }


#market data service
resource "aws_ecs_task_definition" "market_data_task" {
 family             = "trading-services-market-data"
 network_mode       = "awsvpc"
 execution_role_arn = aws_iam_role.ecs_instance_role.arn

 container_definitions = jsonencode([
   {
     name      = "market-data-service"
     image     = "docker.io/kwesidadson/market-data-service:latest"
     cpu                = var.fargate_cpu
     memory = var.fargate_memory
     essential = true
     portMappings = [
       {
         containerPort = 8081
         hostPort      = 8081
         protocol      = "tcp"
       }
     ]
     logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/market-data-service"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
     environment = [
        {
          name  = "SPRING_DATASOURCE_HOST"
          value = var.db_host
        },
        {
          name  = "SPRING_DATASOURCE_USERNAME"
          value = var.db_username
        },
        {
          name  = "SPRING_DATASOURCE_PASSWORD"
          value = var.db_password
        },
         {
          name  = "SPRING_DATASOURCE_DATABASE"
          value = var.db_name
        },
        {
          name  = "SPRING_RABBITMQ_HOST"
          value = var.rabbitmq_host
        },
        {
          name  = "SPRING_RABBITMQ_USER"
          value = var.rabbitmq_username
        },
        {
          name  = "SPRING_RABBITMQ_PASSWORD"
          value = var.rabbitmq_password
        },
        {
          name  = "ELASTICSEARCH_URL"
          value = var.elasticsearch_host
        },
        {
          name  = "ELASTICSEARCH_MASTER_USERNAME"
          value = var.es_username
        },
        {
          name  = "ELASTICSEARCH_MASTER_PASSWORD"
          value = var.es_password
        },
         {
          name  = "REDIS_HOST"
          value = var.redis_host
        },
        {
          name  = "REDIS_PORT"
          value = var.redis_port
        }
      ]
   }
 ])
}

resource "aws_ecs_service" "market_data_service" {
 name            = "market-data-service"
 cluster         = aws_ecs_cluster.main.id
 task_definition = aws_ecs_task_definition.market_data_task.arn
 desired_count   = 1

 network_configuration {
   subnets         = aws_subnet.private.*.id
   security_groups = [aws_security_group.ecs_tasks.id]
 }

 load_balancer {
   target_group_arn = aws_alb_target_group.market_data.arn
   container_name   = "market-data-service"
   container_port   = 8081
 }

  depends_on = [aws_alb_listener.market_data_listener]
}