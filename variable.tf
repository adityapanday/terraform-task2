variable "" {
  required_providers{
    aws = {
        source = "hashicorp/aws"
        version =  "5.84.0"
    }
  }
}



variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
