terraform {
  backend "gcs" {
    bucket = "unipipe-pipeline-bucket"
    prefix = "opendevstack/second-development/terraform.tfstate"

  }

  required_providers {
    local = {
      source = "hashicorp/local"
    }
  }
}
