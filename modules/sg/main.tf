resource "aws_security_group" "sg" {
  name   = var.name
  vpc_id = var.vpc_id

  tags = {
    Name        = var.envname
    Envtype     = var.envtype
    Environment = var.envname
  }
}

resource "aws_security_group_rule" "cidr_rules" {
  count             = length(keys(var.cidr_rules))
  type              = "ingress"
  from_port         = element(var.cidr_rules[element(keys(var.cidr_rules), count.index)], 0)
  to_port           = element(var.cidr_rules[element(keys(var.cidr_rules), count.index)], 1)
  protocol          = element(var.cidr_rules[element(keys(var.cidr_rules), count.index)], 2)
  cidr_blocks       = compact(split(",", element(var.cidr_rules[element(keys(var.cidr_rules), count.index)], 3)))
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "sgid_rules" {
  count                    = var.sgid_rules_count
  type                     = "ingress"
  from_port                = element(var.sgid_rules[element(keys(var.sgid_rules), count.index)], 0)
  to_port                  = element(var.sgid_rules[element(keys(var.sgid_rules), count.index)], 1)
  protocol                 = element(var.sgid_rules[element(keys(var.sgid_rules), count.index)], 2)
  source_security_group_id = element(var.sgid_rules[element(keys(var.sgid_rules), count.index)], 3)
  security_group_id        = aws_security_group.sg.id
}

 resource "aws_security_group_rule" "egress" {
  count             = 1
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sg.id
  cidr_blocks       = ["0.0.0.0/0"]
} 
