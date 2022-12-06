/*
output <output名>{
    value = <outputする値>
}
*/

output "created_subnet" {
  value = aws_subnet.subnets
}