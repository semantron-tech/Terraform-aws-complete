resource "aws_route53_zone" "mydomain" {
  name = "delphin.host"
}


resource "aws_acm_certificate" "cert" {
  domain_name       = "*.delphin.host"
  validation_method = "DNS"

  tags = {
    Environment = "delphin.host"
  }

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_key_pair" "webserver" {
  key_name   = "website-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/gTON3Zfwg+Cl/0y+TuOy6NixqnQHsppL1xOivnCqcLkDyj59x/ex5ET5W1vcjX0bbT87TIR72IO+m+IbgEUzXUWB6Y3QDsCH1IewD1K7bzDl9vluFu9lQnLU7Web86OgP3G3aLe3XcDtLRvZdJYP4G5vc0jpMwd6ZMLULfcDWhoS9xPp8sq+tuxjkoRMaYXtN6TgQCtvtut6RRAqtH86wuj0Wth/O9j4x6rRpZ40p/ccuFFrhs2w3jMp+csdI4yXNMI9QmPN2yS61akLXIWv8r90Arr+Q62zhq9s1w9PBNj9U+Qbgt1egoexB8PAU0ja6rltXrViTODAd9DvZNbV root@delphin-pc"
tags = { name = "webserver"
  }
}




resource "aws_launch_configuration" "lc" {

  name_prefix = "delphin-"
  image_id = "ami-0a0ad6b70e61be944"
  instance_type = "t2.micro"
  key_name = aws_key_pair.webserver.id
  security_groups = [ "sg-0d22368bc021944c9" ]
  user_data = file("setup.sh")
  lifecycle {
    create_before_destroy = true
  }

}



resource "aws_autoscaling_group" "asg" {

  launch_configuration    =  aws_launch_configuration.lc.id
  availability_zones      =  data.aws_availability_zones.all.names
  health_check_type       = "EC2"
  min_size                = "2"
  max_size                = "2"
  desired_capacity        = "2"
  wait_for_elb_capacity   = 2
  load_balancers          = [ "delphin-elb" ]

  tag {
    key = "Name"
    propagate_at_launch = true
    value = "delphin-ec2"
  }

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_elb" "lb" {
  name               = "delphin-elb"
  availability_zones = data.aws_availability_zones.all.names



  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }



  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 443
    lb_protocol       = "https"
   ssl_certificate_id = "arn:aws:acm:us-east-2:151778932168:certificate/a813d571-9bf3-4f63-81e9-a4b02632e057"
  }




  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/index.php"
    interval            = 15
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "delphin-elb"
  }
}


resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.mydomain.zone_id
  name    = "www.delphin.host"
  type    = "A"

  alias {
    name                   = aws_elb.lb.dns_name
    zone_id                = aws_elb.lb.zone_id
    evaluate_target_health = true
  }
}

