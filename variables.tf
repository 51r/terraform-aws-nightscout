variable "name" {
  type        = string
  description = "Specify the prefix name for the AWS resources"
  default     = "nightscout"
}

variable "region" {
  description = "Specify AWS Region"
  default     = "eu-central-1"
}

variable "ami" {
  description = "Specify the AMI ID for your specific region"
  default     = "ami-09042b2f6d07d164a"
}
