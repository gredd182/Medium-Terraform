#---root/main.tf---
module "cluster" {
  source                  = "./cluster"
  public_subnets          = module.networking.public_subnets
  vpc_id                  = module.networking.vpc_id
  endpoint_public_access  = true
  endpoint_private_access = false
  instance_types          = ["t3.small"]
  key_pair                = "terraform"
}

module "networking" {
  source        = "./networking"
  vpc_cidr      = local.vpc_cidr
  public_cidrs  = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_cidrs = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  access_ip     = var.access_ip
}
