### Not used if run as submodule

provider "aws" {
  region = local.region
}
terraform {
  backend "s3" {
    bucket         = "tfstate-vlk-badger" ##TODO change to the name of the terraform bucket created
    key            = "DevOps4DeFi/ourGraph/main.tfstate" ## you can change this too if you want, but only once before you start
    dynamodb_table = "tfstate-locking"
  }
}
