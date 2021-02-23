data "aws_availability_zones" "all" {}


output "az-names" {
    
  value = data.aws_availability_zones.all.names
    
}

output "az-ids" {
    
  value = data.aws_availability_zones.all.zone_ids
    
}

