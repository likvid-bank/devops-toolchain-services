terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "4.22.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.15.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "2.24.0"
    }
  }
}

provider "github" {
  owner = "likvid-bank"
}

provider "google" {
  project = "opendevstack-develop-9gj"
}

provider "azuread" {
  tenant_id = "703c8d27-13e0-4836-8b2e-8390c588cf80" # meshcloud-dev
}

locals {
  project_id = "opendevstack-develop-9gj"
}

# The Instance Repository
resource "github_repository" "instance_repository" {
  name = "devops-toolchain-services"

  visibility  = "private"
  description = "This is the instance repository for the devops toolchain services broker of likvid bank."

  template {
    owner      = "meshcloud"
    repository = "unipipe-instance-repository-template"
  }
}

# The Service Broker Container
module "unipipe" {
  source                = "git@github.com:meshcloud/terraform-gcp-unipipe.git?ref=c758f8f27b0187da467fb8a9fd1dd583935036af"
  project_id            = local.project_id
  unipipe_git_remote    = github_repository.instance_repository.ssh_clone_url
  unipipe_git_branch    = "main"
  cloudrun_service_name = "unipipe"
  region = "europe-west1"
}

# The Service Broker accesses the Instance Broker via a deploy key
resource "github_repository_deploy_key" "unipipe-ssh-key" {
  title      = "unipipe-service-broker-deploy-key"
  repository = github_repository.instance_repository.name
  key        = module.unipipe.unipipe_git_ssh_key
  read_only  = "false"
}

# The Instance Repository has a pipeline for managing services.
# This Service Account is used by the pipeline for managing resources on GCP.
resource "google_service_account" "pipeline_service_account" {
  project       = local.project_id
  account_id   = "unipipe"
  display_name = "UniPipe Pipeline Service Account"
  description  = "Used by unipipe to provision on GCP."
}

resource "google_service_account_key" "pipeline_service_account_key" {
  service_account_id = google_service_account.pipeline_service_account.name
}

# This bucket stores states for instances managed by the pipeline.
resource "google_storage_bucket" "pipeline_bucket" {
  project       = local.project_id
  name          = "unipipe-pipeline-bucket"
  location      = "europe-west1"
  force_destroy = true
}

resource "google_storage_bucket_iam_member" "project" {
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.pipeline_service_account.email}"
  bucket = google_storage_bucket.pipeline_bucket.name
}

resource "github_actions_secret" "gcp_service_account" {
  repository      = github_repository.instance_repository.name
  secret_name     = "GOOGLE_CREDENTIALS"
  plaintext_value = base64decode(google_service_account_key.pipeline_service_account_key.private_key)
}

# This Service Principal is used by the pipeline for managing resources on Azure.
resource "azuread_application" "pipeline_application" {
  display_name = "UniPipe Pipeline Application"

  web {
    implicit_grant {
      access_token_issuance_enabled = false
    }
  }

}

resource "azuread_service_principal" "pipeline_service_principal" {
  application_id = azuread_application.pipeline_application.application_id
}

resource "azuread_service_principal_password" "pipeline_service_principal_pw" {
  service_principal_id = azuread_service_principal.pipeline_service_principal.id
  end_date             = "2999-01-01T01:02:03Z" # no expiry
}

resource "github_actions_secret" "arm_client_id" {
  repository      = github_repository.instance_repository.name
  secret_name     = "ARM_CLIENT_ID"
  plaintext_value = azuread_service_principal.pipeline_service_principal.id
}

resource "github_actions_secret" "arm_client_secret" {
  repository      = github_repository.instance_repository.name
  secret_name     = "ARM_CLIENT_SECRET"
  plaintext_value = azuread_service_principal_password.pipeline_service_principal_pw.value

}

resource "github_actions_secret" "arm_tenant_id" {
  repository      = github_repository.instance_repository.name
  secret_name     = "ARM_TENANT_ID"
  plaintext_value = "703c8d27-13e0-4836-8b2e-8390c588cf80" # meshcloud-dev
}
