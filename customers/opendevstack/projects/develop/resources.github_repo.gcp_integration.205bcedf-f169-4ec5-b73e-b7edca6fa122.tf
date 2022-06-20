module "github_repo_binding_status_205bcedf-f169-4ec5-b73e-b7edca6fa122" {
  source   = "../../../../modules/status"
  
  instances_dir = "${path.cwd}/../../../../instances"
  binding      = {"bindResource":{"platform":"gcp.gcp-meshstack-dev","tenant_id":"opendevstack-develop-9gj"},"bindingId":"205bcedf-f169-4ec5-b73e-b7edca6fa122","context":{"auth_url":null,"customer_id":"opendevstack","permission_url":null,"platform":"meshmarketplace","project_id":"develop","token_url":null},"deleted":false,"originatingIdentity":{"platform":"meshmarketplace","user_euid":"fzieger@example.com","user_id":"75606cd5-2251-4134-9e46-1604f001312b"},"parameters":{},"planId":"B17F389D-7ECD-4522-98AF-5E2289B68A97","serviceDefinitionId":"E1A838DE-AA9C-4DED-A23C-24824BC1B192","serviceInstanceId":"ff52aa26-9393-4021-91e4-e0a9c6c1343e"}
  success       = true
  description   = "Updated binding successfully"
}

resource "github_repository_file" "maintf" {
  repository          = github_repository.managed.name
  commit_message      = local.commit_message
  commit_author       = local.commit_author
  commit_email        = local.commit_email

  file                = "main.tf"
  content             = <<-EOT
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.15.0"
    }
  }
}

provider "google" {
}
  EOT
}

resource "github_repository_file" "pipelineyml" {
  repository          = github_repository.managed.name
  commit_message      = local.commit_message
  commit_author       = local.commit_author
  commit_email        = local.commit_email

  file                = ".github/workflows/pipeline.yml"
  content             = <<-EOT
name: Deploy

on:
  push:
    branches:
      - "main"

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: write
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v1
      - id: 'auth'
        name: 'Authenticate to Google Cloud'
        uses: 'google-github-actions/auth@v0.4.0'
        with:
          workload_identity_provider: $${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }}
          service_account: $${{ secrets.GCP_SERVICE_ACCOUNT }}
      - run: terraform init
      - run: terraform apply -auto-approve
      - name: git
        run: |
          git config --global user.email "team@example.com"
          git config --global user.name "Infrastructure Bot"
          git add .
          git diff-index --quiet HEAD || git commit -m "Update Infrastructure"
          git push
  EOT
}

module "github_actions_sa" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 4.0"
  project_id = "opendevstack-develop-9gj"
  names        = ["githubactionssa"]
  display_name = "Github Actions SA"
  project_roles = ["opendevstack-develop-9gj=>roles/owner"]
}

module "gh_oidc" {
  source         = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id     = "opendevstack-develop-9gj"
  pool_id        = "github-identity-pool"
  provider_id    = "github-identity-provider"
  sa_mapping     = {
    "my_service_account" = {
      sa_name   = "projects/opendevstack-develop-9gj/serviceAccounts/${module.github_actions_sa.email}"
      attribute = "attribute.repository/likvid-bank/dev"
    }
  }
}

resource "github_actions_secret" "gcp_workload_identity_provider" {
  repository       = github_repository.managed.name
  secret_name      = "GCP_WORKLOAD_IDENTITY_PROVIDER"
  plaintext_value  = module.gh_oidc.provider_name
}

resource "github_actions_secret" "gcp_service_account" {
  repository       = github_repository.managed.name
  secret_name      = "GCP_SERVICE_ACCOUNT"
  plaintext_value  = module.github_actions_sa.email
}
