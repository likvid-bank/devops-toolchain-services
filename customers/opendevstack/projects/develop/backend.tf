terraform {
  backend "gcs" {
    bucket = "unipipe-pipeline-bucket"
    prefix = "opendevstack/develop/terraform.tfstate"

  }

  required_providers {
    local = {
      source = "hashicorp/local"
    }
  }
}
