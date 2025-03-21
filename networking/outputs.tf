#--- networking/outputs.tf ---
output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

##--- instance outputs
output "instance_sg" {
  description = "select ec2 security group from locals variable in the root file"
  value       = aws_security_group.alb_sg.id 
}

# Output Public Subnet IDs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public_subnet[*].id
}

# Output Private Subnet IDs
output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private_subnet[*].id
}

# Output Internet Gateway ID
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

# Output Public Route Table ID
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public_rt.id
}
# Output Public Route Table ID
output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private_rt.id
}
