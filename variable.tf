variable "vpc_cidr" {
  description = "This CIDR block for the VPC"
  type        = string
  default     = "10.124.0.0/16"
}

# variable "public_subnet_cidr" {
#   description = "List of public subnet CIDRs"
#   type        = list(string)
#   default     = ["10.124.1.0/24", "10.124.2.0/24"]
# }

# variable "private_subnet_cidr" {
#   description = "List of private subnet CIDRs"
#   type        = list(string)
#   default     = ["10.124.3.0/24", "10.124.4.0/24"]
# }
variable "access_ip" {
  description = "The IP address allowed to access the instances"
  type        = string
  default     = "0,0,0,0/0"
}

variable "instance_type" {
    description = "The type of instance to use for the web server"
    type        = string
    default     = "t2.micro"
}

variable "main_instance_count" {
  description = "Number of main instances to launch"
  type        = number
  default     = 1
}

variable "key_name" {
  description = "The name of the key pair to use for SSH access"
  type        = string
  default     = "id_rsa"
}

variable "public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "C:/Users/Abhishek Yadav/.ssh/terraform_key.pub"
}


variable "private_key_path" {
  description = "Path to the SSH private key file"
  type        = string
  default     = "C:/Users/Abhishek Yadav/.ssh/terraform_key"
}

