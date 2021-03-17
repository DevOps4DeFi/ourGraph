locals {
  vpc_id   = var.vpc_id
  vpc_cidr = data.aws_vpc.vpc.cidr_block
  subnets  = var.subnet_ids
}

data "aws_vpc" "vpc" {
  id    = var.vpc_id
}


