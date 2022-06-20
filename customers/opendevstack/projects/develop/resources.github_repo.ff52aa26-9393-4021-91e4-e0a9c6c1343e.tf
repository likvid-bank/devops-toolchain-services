provider "github" {
  app_auth {}
  owner = "likvid-bank"
}

resource "github_repository" "managed" {
  name        = "opendevstack-develop-dev"
  description = "Infrastructure repository for project develop of customer opendevstack."

  gitignore_template = "Terraform"
  auto_init          = true

  visibility = "private"
  # We would like to use a template, but this is currently not supported for GitHub App Installations
  # See https://docs.github.com/en/rest/reference/repos#create-a-repository-using-a-template
  # Workaround: Create files main.tf and .github/workflow/pipeline.yml manually (see gcp_integration terraform template)
}

locals {
  commit_message = "Welcome Package by DevOps Toolchain Team"
  commit_author  = "DevOps Toolchain Team"
  commit_email   = "devopstoolchain@likvid-bank.com"
}
