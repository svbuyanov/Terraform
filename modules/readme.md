# New Environment Template

## Notes:
1. This requires __Terraform >=0.12.6__.
2. __modules__ folder contains  for VPC EC2 SG, more modules could be extracted in the future.



---

## VPC public private subnet 

  *_Amazon AWS VPC_
  *_Internet Gateway_
  *_Subnets in all configured availability zones and routing tables linking them to the Internet Gateway_ 

  *Additionally, if variable `private_subnets` is set to true, it will create:
  *commented in module  
  *NAT with Elastic IP address in each availability zone
  *Private subnet in each availability zone with routing tables linking them to the NAT
## Usage
```hcl
module "vpc" {
  source = "../../modules/vpc"

  aws_region = "us-east-1"
  aws_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_name = "prod-vpc"
  vpc_cidr = "10.0.0.0/16"
  private_subnets = "true"

  ## Tags
  tags = {
    Name = "stage"
  }
}
```

## EC2 

  -Dynamic EC2 Instance Count
  -Keypair can be attached automatically
  -Startup Script can be attached as "User Data"


## Usage
```hcl
module "ec2" {
    source  = "../../modules/ec2"
    region  = "us-east-1"
    subnet_id = "subnet-0dbf08e5b2e643c93"
    security_group_ids = ["sg-060b6d3d454ebe5f4"]
    nb_instances        = "1"
    instance_type       = "t2.micro"
    instance_set_name   = "uat"
    associate_public_ip_address = "true"
    ssh_key_name        = "test"
    ssh_public_key      = file("../../modules/ext/id_rsa.pub")
    ami_id              = "ami-09d8b5222f2b93bf0"
    data_volume_size          = "20"
    instance_tags       = {
                            Client = "apple"
                            Data  = "sensitive"    
                            environment = "prodaction"
                            Name = "apple-prod-backend"
                            Terraform = "true"
                            Backup = "true"
                            
                        }
                        user_data = file("../../modules/ext/efs.tpl")


}
```

## Secirity Groups 

## Usage

```hcl
# security groups

# this data extract information about vpc id. information extracted by tag Name =prod
provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "prod" {
  filter {
    name = "tag:Name"
    values = ["prod"] 
  }
}

module "general" {
  source  = "../../modules/sg"
  region  = "us-east-1"
  name    = "RDS"
  envname = "prod"
  envtype = "test"
  vpc_id  = "vpc-0"
  

  cidr_rules = {
    icmp                   = [-1, -1, "icmp", "0.0.0.0/0"]
    zabbix                 = [10500, 10500, "tcp", "10.10.10.10/32"]
    knocking               = [7658, 7659, "tcp", "192.168.1.0/24,10.10.10.10/32"]
    https                  = [443, 443, "tcp", "192.168.1.0/24"]
    kport-rule             = [8080, 8080, "tcp", "192.168.1.0/24"]
    docker                 = [5000, 5000, "tcp", "192.168.1.0/24"]
    
  }

  sgid_rules = {
    from_bastions = [5000, 5000, "tcp", "sg-0bcd"]
    from_jenkins = [6000, 6000, "tcp", "sg-0bc"]
  }

  sgid_rules_count = 2

  
}

module "generalone" {
  source  = "../../modules/sg"
  region  = "us-east-1"
  name    = "ec2"
  envname = "prod"
  envtype = "test"
  vpc_id  = "vpc-0b23"

  cidr_rules = {
    icmp                   = [-1, -1, "icmp", "0.0.0.0/0"]
    zabbix                 = [10500, 10500, "tcp", "10.10.10.10/32"]
    web-rule               = [80, 80, "tcp", "192.168.1.0/24,10.10.10.10/32"]
    rulegttps              = [443, 443, "tcp", "192.168.1.0/24"]
    some-rule              = [8080, 8080, "tcp", "192.168.1.0/24"]
    docker                 = [5000, 5000, "tcp", "192.168.1.0/24"]
    
  }
}
```
## ALB 

## Usage need to be improve use data from AWS like vpc subnet  security group
```hcl

provider "aws" {
 region     = "us-east-1"
}

module "alb" {
   source = "../../modules/alb"
   envname = "dev"
   service = "test"
   name = "test"
   subnets = ["subnet-003895", "subnet-0a6"]
   security_groups = ["sg-012c"]
   enable_http_listener = true
   enable_https_listener = true
   vpc_id = "vpc-of2345d"
   certificate_arn = "arn:aws:acm:us-east-1:676383077486:certificate/4c0d0217-ac4c-4715-a208-fed40e2e6d03"
   access_logs_enabled = true
   access_logs_bucket = "test"
   access_logs_prefix = "alb_logs"
   http_stickiness = true
   target_health_check_path = "/status"
   target_health_check_port = "443"
   target_health_check_matcher = "200"

}


output "default_target_group_arn" {
  value = module.alb.default_target_group_arn
}

```
