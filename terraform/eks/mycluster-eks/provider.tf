# Providers config
provider "aws" {
  shared_credentials_file = var.credentials_file
  profile                 = var.profile
  region                  = var.region
  version                 = ">= 3.22.0"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = ">= 1.11.2"
}

provider "random" {
  version = ">= 2.2.1"
}

provider "local" {
  version = ">= 1.4.0"
}

provider "template" {
  version = ">= 2.1.2"
}

provider "null" {
  version = ">= 2.1.2"
}

terraform {
  required_version = ">= 0.12.19, < 0.13.0"
}

