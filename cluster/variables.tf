#---cluster/variables.tf---

variable "public_subnets" {
    
}

variable "vpc_id" {
  
}
variable "kms_arn" {
  type        = string
  description = "The ARN of the KMS key to be used by the EKS cluster."
}


variable "endpoint_private_access" {
  default = true  # Replace with your desired value (true or false)
}

variable "endpoint_public_access" {
  default = false  # Replace with your desired value (true or false)
}

variable "instance_types" {
  default = ["t2.micro"]  # Replace with your desired instance types
}

variable "key_pair" {
  default = "terraform"  # Replace with the name of your key pair
}
