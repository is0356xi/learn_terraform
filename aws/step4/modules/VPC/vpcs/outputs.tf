/*
output <output名>{
    value = <outputする値>
}
*/

output "created_vpc" {
  value = aws_vpc.vpc
}