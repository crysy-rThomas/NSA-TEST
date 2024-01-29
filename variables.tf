#### network

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "cidr_route" {
  default = "0.0.0.0/0"
}

####instances 

variable "instance_type" {
  default = "t2.micro"
}