resource "aws_key_pair" "webserver" {
  key_name   = "website-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/gTON3Zfwg+Cl/0y+TuOy6NixqnQHsppL1xOivnCqcLkDyj59x/ex5ET5W1vcjX0bbT87TIR72IO+m+IbgEUzXUWB6Y3QDsCH1IewD1K7bzDl9vluFu9lQnLU7Web86OgP3G3aLe3XcDtLRvZdJYP4G5vc0jpMwd6ZMLULfcDWhoS9xPp8sq+tuxjkoRMaYXtN6TgQCtvtut6RRAqtH86wuj0Wth/O9j4x6rRpZ40p/ccuFFrhs2w3jMp+csdI4yXNMI9QmPN2yS61akLXIWv8r90Arr+Q62zhq9s1w9PBNj9U+Qbgt1egoexB8PAU0ja6rltXrViTODAd9DvZNbV root@delphin-pc"
tags = { name = "webserver"
  }
}





resource "aws_security_group" "bastion" {
    
    
  name        = "blog bastion"
  description = "allow 22 only"
  vpc_id = aws_vpc.myvpc.id
    
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "blog-bastion"
  }
}





resource "aws_security_group" "webserver" {


  name        = "webserver"
  description = "allow 22,80,443 only"
  vpc_id      =  aws_vpc.myvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  security_groups = [ aws_security_group.bastion.id ]
  }


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webserver"
  }
}








resource "aws_security_group" "mysql" {


  name        = "mysql"
  description = "allow 22,3306  only"
  vpc_id      =  aws_vpc.myvpc.id


ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [ aws_security_group.bastion.id ]
  }


  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [ aws_security_group.webserver.id ]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysql"
  }
}








resource "aws_instance" "bastion" {
    
  ami                            = var.ec2.ami
  instance_type                  = var.ec2.type
  associate_public_ip_address    = true
  vpc_security_group_ids         = [ aws_security_group.bastion.id  ]
  subnet_id                      = aws_subnet.public3.id
  key_name                       = aws_key_pair.webserver.id
  tags = {
    Name = "bastion"
  }
  
}


#######################################################################
# webserver
#######################################################################

resource "aws_instance" "webserver" {
    
  ami                            = var.ec2.ami
  instance_type                  = var.ec2.type
  associate_public_ip_address    = true
  vpc_security_group_ids         = [ aws_security_group.webserver.id  ]
  subnet_id                      = aws_subnet.public2.id
  key_name                       = aws_key_pair.webserver.id
  tags = {
    Name = "webserver"
  }
  
}

#######################################################################
# databse
#######################################################################

resource "aws_instance" "database" {
    
  ami                            = var.ec2.ami
  instance_type                  = var.ec2.type
  vpc_security_group_ids         = [ aws_security_group.mysql.id  ]
  subnet_id                      = aws_subnet.private1.id
  key_name                       = aws_key_pair.webserver.id
  tags = {
    Name = "database"
  }
  
}







resource "aws_vpc" "myvpc" {
  cidr_block       = var.vpc.cidr
  instance_tenancy = "default"
  enable_dns_hostnames  = true
  tags = {
    Name = var.vpc.tag
  }
}



resource "aws_subnet" "public1" {
    
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.public1.cidr
  availability_zone = var.public1.az
  map_public_ip_on_launch = true
  tags = {
    Name = var.public1.tag
  }
}


resource "aws_subnet" "public2" {

  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.public2.cidr
  availability_zone = var.public2.az
  map_public_ip_on_launch = true
  tags = {
    Name = var.public2.tag
  }
}


resource "aws_subnet" "public3" {

  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.public3.cidr
  availability_zone = var.public3.az
  map_public_ip_on_launch = true
  tags = {
    Name = var.public3.tag
  }
}


resource "aws_subnet" "private1" {

  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.private1.cidr
  availability_zone = var.private1.az
  map_public_ip_on_launch = false
  tags = {
    Name = var.private1.tag
  }
}


resource "aws_subnet" "private2" {

  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.private2.cidr
  availability_zone = var.private2.az
  map_public_ip_on_launch = false
  tags = {
    Name = var.private2.tag
  }
}


resource "aws_subnet" "private3" {

  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.private3.cidr
  availability_zone = var.private3.az
  map_public_ip_on_launch = false
  tags = {
    Name = var.private3.tag
  }
}



resource "aws_internet_gateway" "myIGW" {

  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = var.igw
  }
}


resource "aws_eip" "natip" {
  vpc      = true
}


resource "aws_nat_gateway" "myNAT" {

  allocation_id = aws_eip.natip.id
  subnet_id     = aws_subnet.public3.id

  tags = {
    Name = var.nat
  }
}



resource "aws_route_table" "publicRT" {

  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }

  tags = {
    Name = var.route_public
  }
}




resource "aws_route_table" "privateRT" {

  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.myNAT.id
  }

  tags = {
    Name = var.route_private
  }
}





resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.publicRT.id
}


resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.publicRT.id
}


resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.publicRT.id
}




resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.privateRT.id
}



resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.privateRT.id
}


resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.privateRT.id
}





