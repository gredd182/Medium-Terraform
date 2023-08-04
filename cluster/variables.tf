#---cluster/variables.tf---

variable "public_subnets" {
  default = ["subnet-1", "subnet-2", "subnet-3"]  # Replace with the actual subnet IDs
}

variable "vpc_id" {
  default = "vpc-1234567890"  # Replace with the actual VPC ID
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
