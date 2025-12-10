terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }


backend "s3" {
  bucket         = "devops-automation-demo-11122334-abhishekk"
  key            = "terraform.tfstate"
  region         = "us-east-1"
  use_lockfile = true
  encrypt        = true
} 
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zone" "available" {
  name = "us-east-1a"  
}

locals{
  azs = data.aws_availability_zone.available
}





resource "random_id" "random" {
  byte_length = 2
}
  


resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true




lifecycle {
  create_before_destroy = true
}

tags = {
  Name  = "main-vpc-project-${random_id.random.dec}"
}
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw-project-${random_id.random.dec}"
    
  }
  
  }

resource "aws_subnet" "public_subnet" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr,8,count.index) 
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}-project-${random_id.random.dec}"
  }
  
}

resource "aws_subnet" "private_subnet" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr,8,count.index + length(local.azs)) 
 // availability_zone = local.azs[count.index]

  tags = {
    Name = "private-subnet-${random_id.random.dec}-${count.index + 1}"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table-${random_id.random.dec}"
  }
}


resource "aws_route_table_association" "public_rt_assoc" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
  
}


