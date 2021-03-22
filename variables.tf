variable "ethnode_url_ssm_parameter_name" {
  type        = string
  description = "the name of an ssm parameter that holds the URL of the ethnode we will use"
}

variable "app_name" {
  type        = string
  description = "The name of the application that will be used for tagging."
  default     = "local-graphnode-cluster"
}
variable "aws_keypair_name" {
  type        = string
  description = "The name of the ssh keypair to use in order to allow access."
}
variable "route53_root_fqdn" {
  type        = string
  description = "Root route53 domain name that we should build records on top of."
}
variable "region" {
  type        = string
  description = "The aws region to deploy into."
}
variable "subnet_ids" {
  type        = list(string)
  default     = null
  description = "a list of subnet ids to launch the instance in, recommend private."
}
variable "vpc_id" {
  type        = string
  default     = null
  description = "The VPC to deploy into, if null use default vpc."
}
variable "rds_instance_type" {
  type = string
  default = null
  description = "Specify an instance type like db.m5.large and instance size to use a separate rds db"
}
variable "rds_storage_size" {
  type = number
  default = null
  description = "Max size in GB the rds db can grow to, if not specified use docker local postgres"
}
variable "rds_monitoring_role_arn" {
  type = string
  description = "the arn of an rds monitoring role if rds is in use, if none is provided, we will try to create one"
  default = null
}
variable "network" {
  type = string
  description = "mainnet for eth, bsc for bsc"
  default = "mainnet"
}
##TODO add support for private subents
variable "asg_details" {
  type = object({ instance_type = string, min_nodes = number, desired_nodes = number, max_nodes = number, storage_size_gb = number })
  default = {
    instance_type   = "t2.micro"
    min_nodes       = 1
    max_nodes       = 1
    desired_nodes   = 1
    storage_size_gb = "15"
  }
  description = "How many of which instance type for the autoscailing group.  Defaults to 1 t2.micro for free tier."
}


variable "lb_https_listener_arn" {
  type=string
  description = "The arn to an https alb listener that will be used."
}
variable "lb_name" {
  type=string
  description = "The name of the  alb running the specified listener"
}

variable "tags" {
  default = {}
}

variable "ssm_root" {
  default = "/DevOps4DeFi"
}
