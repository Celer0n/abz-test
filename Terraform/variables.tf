variable "region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "ami" {
  description = "AMI VM"
  type        = string
  default = "ami-0a422d70f727fe93e"
}

variable "instance_type" {
  description = "VM type"
  type        = string
  default     = "t2.micro"
}