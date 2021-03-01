#########################
### Base Params Start ###
#########################
variable "client_name" {
  description = "Short name of the client"
  type        = string
}

variable "client_env" {
  description = "Client environment type (prod/train/uat...)"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
}

variable "aws_region" {
  description = "AWS region to launch resources."
  default     = "us-east-1"
}