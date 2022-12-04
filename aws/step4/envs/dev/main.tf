module "vpc" {
  source     = "../../modules/Vpc/vpc"
  env_params = var.env_params

  vpc_params = var.vpc_params
}

module subnet{
  source = "../../modules/Vpc/subnet"
  env_params = var.env_params

  subnet_params = var.subnet_params
  created_vpc = module.vpc.created_vpc

}

output "debug" {
  value = {
    created_vpc = module.vpc.created_vpc,
    created_subnet = module.subnet.created_subnet
  }
}