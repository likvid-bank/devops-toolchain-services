module "github_repo_binding_status_f6382f6e-a167-49a1-8fb8-d88e5f285611" {
  source   = "../../../../modules/status"
  
  instances_dir = "./../../../../instances"
  binding      = {"bindResource":{"platform":"gcp.gcp-meshstack-dev","tenant_id":"opendevstack-second-dev-hk6"},"bindingId":"f6382f6e-a167-49a1-8fb8-d88e5f285611","context":{"auth_url":null,"customer_id":"opendevstack","permission_url":null,"platform":"meshmarketplace","project_id":"second-development","token_url":null},"deleted":false,"originatingIdentity":{"platform":"meshmarketplace","user_euid":"fzieger@meshcloud.io","user_id":"75606cd5-2251-4134-9e46-1604f001312b"},"parameters":{},"planId":"B17F389D-7ECD-4522-98AF-5E2289B68A97","serviceDefinitionId":"E1A838DE-AA9C-4DED-A23C-24824BC1B192","serviceInstanceId":"729d125a-7f11-4109-9a19-4e20c0fa4662"}
  success       = true
  description   = "Updated binding successfully"
}

resource "github_repository_file" "maintf_f6382f6e-a167-49a1-8fb8-d88e5f285611" {
  repository          = github_repository.managed_729d125a-7f11-4109-9a19-4e20c0fa4662.name
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

resource "github_repository_file" "pipelineyml_f6382f6e-a167-49a1-8fb8-d88e5f285611" {
  repository          = github_repository.managed_729d125a-7f11-4109-9a19-4e20c0fa4662.name
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

module "github_actions_sa_f6382f6e-a167-49a1-8fb8-d88e5f285611" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 4.0"
  project_id = "opendevstack-second-dev-hk6"
  names        = ["githubactionssa"]
  display_name = "Github Actions SA"
  project_roles = ["opendevstack-second-dev-hk6=>roles/owner"]
}

module "gh_oidc_f6382f6e-a167-49a1-8fb8-d88e5f285611" {
  source         = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id     = "opendevstack-second-dev-hk6"
  pool_id        = "github-identity-pool"
  provider_id    = "github-identity-provider"
  sa_mapping     = {
    "my_service_account" = {
      sa_name   = "projects/opendevstack-second-dev-hk6/serviceAccounts/${module.github_actions_sa_f6382f6e-a167-49a1-8fb8-d88e5f285611.email}"
      attribute = "attribute.repository/likvid-bank/second-dev"
    }
  }
}

resource "github_actions_secret" "gcp_workload_identity_provider_f6382f6e-a167-49a1-8fb8-d88e5f285611" {
  repository       = github_repository.managed_729d125a-7f11-4109-9a19-4e20c0fa4662.name
  secret_name      = "GCP_WORKLOAD_IDENTITY_PROVIDER"
  plaintext_value  = module.gh_oidc_f6382f6e-a167-49a1-8fb8-d88e5f285611.provider_name
}

resource "github_actions_secret" "gcp_service_account_f6382f6e-a167-49a1-8fb8-d88e5f285611" {
  repository       = github_repository.managed_729d125a-7f11-4109-9a19-4e20c0fa4662.name
  secret_name      = "GCP_SERVICE_ACCOUNT"
  plaintext_value  = module.github_actions_sa_f6382f6e-a167-49a1-8fb8-d88e5f285611.email
}

moved {
  from = github_repository_file.maintf 
  to   = github_repository_file.maintf_f6382f6e-a167-49a1-8fb8-d88e5f285611
}
moved {
  from = github_repository_file.pipelineyml 
  to   = github_repository_file.pipelineyml_f6382f6e-a167-49a1-8fb8-d88e5f285611
}
moved {
  from = module.github_actions_sa
  to   = module.github_actions_sa_f6382f6e-a167-49a1-8fb8-d88e5f285611
}
moved {
  from = module.gh_oidc
  to   = module.gh_oidc_f6382f6e-a167-49a1-8fb8-d88e5f285611
}
moved {
  from = github_actions_secret.gcp_workload_identity_provider
  to   = github_actions_secret.gcp_workload_identity_provider_f6382f6e-a167-49a1-8fb8-d88e5f285611
}
moved {
  from = github_actions_secret.gcp_service_account
  to   = github_actions_secret.gcp_service_account_f6382f6e-a167-49a1-8fb8-d88e5f285611
}
