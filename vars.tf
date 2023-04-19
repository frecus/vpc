variable "aws_region" {
  default = "eu-west-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnets_cidr" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
  # private, public
}


variable "ami_type" {
  type    = list(any)
  default = ["ami-0aef57767f5404a3c", "ami-0aef57767f5404a3c", "ami-0aef57767f5404a3c"]
}

variable "instance_count" {
  default = "3"
}

variable "instance_tags" {
  type    = list(any)
  default = ["test-p1", "test-p2", "test-p3"]
}

variable "instance_type" {
  type    = list(any)
  default = ["t2.micro", "t2.micro", "t2.micro"]
}
