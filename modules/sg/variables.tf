/* Environment variables */

variable "name" {
  description = "The name of the AWS Security Group, also second name label for the 'Name' tag"
  type        = string
}

variable "envname" {
  description = "The first name label for the 'Name' tag, and the value for the 'Environment' tag"
  type        = string
}

variable "envtype" {
  description = "The value for the 'EnvType' tag"
  type        = string
}

/* Security Group variables */
variable "vpc_id" {
  description = "The ID of the VPC the Security Group rules should target"
  type        = string
}

variable "egress" {
  description = "Bool indicating whether to enable an 'all' egress rule for the specified VPC"
  type        = string
  default     = false
}

variable "cidr_rules" {
  description = "Map of lists for CIDR rules. from_port=0, to_port=1, protocol=2, cidr_blocks=3 (cidr_blocks is a comma seperated string)"
  type        = map
  default     = {}
}

variable "sgid_rules" {
  description = "Map of lists for Security Group ID based rules. from_port=0, to_port=1, protocol=2, (security group ids)=3"
  type        = map
  default     = {}
}

variable "sgid_rules_count" {
  default = 0
}
