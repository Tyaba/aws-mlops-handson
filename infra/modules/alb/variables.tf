variable "alb_security_group" {
  description = "security group id for application load balancer"
}

variable "alb_subnets" {
  description = "List of public subnet ids to place to application load balancer"
}

variable "vpc_id" {
  description = "VPC ID to place target group"
}

variable "prefix" {
  description = "The prefix to use for all resources in this example."
}