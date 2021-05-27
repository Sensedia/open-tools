# Providers config
provider "aws" {
  shared_credentials_file = var.credentials_file
  profile                 = var.profile
  region                  = var.region
  version                 = ">= 2.61.0"
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

