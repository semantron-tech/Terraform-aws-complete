variable "vpc" {
  type = map
  default = {
    "cidr" = "172.16.0.0/16"
    "tag"  = "myvpc"   
  }  
}



variable "public1" {
  type = map
  default = {
    "cidr" = "172.16.0.0/20"
    "tag"  = "myvpc-public-1"
    "az"   = "us-east-2a"
  }
}


variable "public2" {
  type = map
  default = {
    "cidr" = "172.16.16.0/20"
    "tag"  = "myvpc-public-2"
    "az"   = "us-east-2b"
  }
}

variable "public3" {
  type = map
  default = {
    "cidr" = "172.16.32.0/20"
    "tag"  = "myvpc-public-3"
    "az"   = "us-east-2c"
  }
}


# =======================================================


variable "private1" {
  type = map
  default = {
    "cidr" = "172.16.48.0/20"
    "tag"  = "myvpc-private-1"
    "az"   = "us-east-2a"
  }
}

variable "private2" {
  type = map
  default = {
    "cidr" = "172.16.64.0/20"
    "tag"  = "myvpc-private-2"
    "az"   = "us-east-2b"
  }
}

variable "private3" {
  type = map
  default = {
    "cidr" = "172.16.80.0/20"
    "tag"  = "myvpc-private-3"
    "az"   = "us-east-2c"
  }
}


variable "igw" {

  default = "myIGW"
}


variable "nat" {
  default = "myNAT"
}


variable "route_public" {
    
  default = "myroute-public"
}

variable "route_private" {
    
  default = "myroute-private"
}


variable "ec2" {
  type = map
  default = {
    "ami" = "ami-0a0ad6b70e61be944"
    "type"  = "t2.micro"
  }
}

