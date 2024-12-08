variable "region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "ami" {
  description = "AMI VM"
  type        = string
  default = "ami-02141377eee7defb9"
}

variable "instance_type" {
  description = "VM type"
  type        = string
  default     = "t2.micro"
}