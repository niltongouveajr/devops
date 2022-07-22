provider "aws" {
  version                 = "~> 3.13.0"
  region                  = var.region
  shared_credentials_file = var.credentials
  profile                 = var.profile
}
