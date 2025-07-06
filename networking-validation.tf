##########################
# Subnet Validation
##########################
data "aws_vpc" "default" { # Finds our default VPC.
  default = true
}

data "aws_subnet" "from_subnet_ids" {
  for_each = toset(var.subnet_ids)
  id       = each.value

  lifecycle {
    # Checks if the subnet_ids argument does not reference subnets inside the default VPC. If it does, returns an error message-
    # -then prevents the creation of downstream resources (such as the RDS instance).
    postcondition {
      condition     = self.vpc_id != data.aws_vpc.default.id
      error_message = <<-EOT
      The RDS instance is being deployed at the following subnet(s) which is/are being deployed at the default VPC:

      Name(s): ${self.tags.Name}
      ID(s)  : ${self.id})

      Please do not deploy anything at the default VPC for better security.
      EOT
    }

    # Checks if the subnet's Access tag is populated and is set to "private". If it is not, returns an error message.
    postcondition {
      condition     = (lower(lookup(self.tags, "Access", "")) == "private") # "lower" function ensures string is not case sensitive.
      error_message = <<-EOT
      The following subnet(s) do not have Access tags marked as "private":

      Name(s): ${self.tags.Name}
      ID(s)  : ${self.id})

      Please mark the subnet(s) as Access = "private".
      EOT
    }
  }
}

###################################################################
# Security Group Validation
###################################################################
data "aws_vpc_security_group_rules" "from_vpc_security_group_ids" {
  filter {
    name   = "group-id"
    values = var.vpc_security_group_ids
  }
}

data "aws_vpc_security_group_rule" "from_vpc_security_group_ids" {
  # TBH, I got this "for_each" from ChatGPT and I can't be bothered explain this monstrosity but trust me, this is the only way for this to work.
  # All I can say is that it references the aws_vpc_security_group_rules data source and then creates multiple instances of this data source.
  for_each = (data.aws_vpc_security_group_rules.from_vpc_security_group_ids.ids != null ?
    toset(data.aws_vpc_security_group_rules.from_vpc_security_group_ids.ids) :
  toset([]))
  security_group_rule_id = each.value

  lifecycle {
    # 1. All outbound rules are allowed but- 
    # 2. -for inbound rules, the ipv4 and ipv6 attributes must be empty and the referenced security_group_rule_id attribute must not empty.
    # 3. If any of the conditions in 2 are still not met, returns an error message.
    postcondition { # Attributes are obtained from the documetation page under "Attribute Reference".
      condition = (self.is_egress ? true :
        self.cidr_ipv4 == null
        && self.cidr_ipv6 == null
        && self.referenced_security_group_id != null
      )
      error_message = <<-EOT
      The following security group(s) contain an invalid inbound rule:

      ID = ${self.security_group_id}

      Please ensure that the rules do not allow inbound traffic from IPv4 and/or IPv6 CIDR blocks, only from other security groups.
      EOT
    }
  }
}