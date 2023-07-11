variable "aws_region" {
  type        = string
  description = "AWS AZ"
  default     = "us-east-1"
}

variable "app_name" {
  type    = string
  default = "nginx" # Do NOT enter any spaces
}

variable "app_environment" {
  type    = string
  default = "development" # Dev, Test, Staging, Prod, etc
}

variable "linux_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "linux_root_volume_size" {
  type    = string
  default = 20
}

variable "linux_root_volume_type" {
  type    = string
  default = "gp2"
}
