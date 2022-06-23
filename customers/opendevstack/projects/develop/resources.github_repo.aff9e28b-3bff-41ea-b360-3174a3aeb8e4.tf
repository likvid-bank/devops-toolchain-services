resource "github_repository" "managed_aff9e28b-3bff-41ea-b360-3174a3aeb8e4" {
  name        = "opendevstack-develop--ci"
  description = "Infrastructure repository for project develop of customer opendevstack."

  gitignore_template = "Terraform"
  auto_init          = true

  visibility = "private"
  # We would like to use a template, but this is currently not supported for GitHub App Installations
  # See https://docs.github.com/en/rest/reference/repos#create-a-repository-using-a-template
  # Workaround: Create files main.tf and .github/workflow/pipeline.yml manually (see gcp_integration terraform template)
}

moved {
  from = github_repository.managed
  to   = github_repository.managed_aff9e28b-3bff-41ea-b360-3174a3aeb8e4
}
