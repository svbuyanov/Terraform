module "vpc" {
  source = "../../modules/vpc"

  aws_region = "us-east-1"
  aws_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_name = "prod-vpc"
  vpc_cidr = "10.0.0.0/16"
  private_subnets = "true"

  ## Tags
  tags = {
    Name = "prod"
  }
}
