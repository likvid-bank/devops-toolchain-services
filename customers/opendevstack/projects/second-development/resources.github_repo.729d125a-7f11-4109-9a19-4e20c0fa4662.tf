resource "github_repository" "managed_729d125a-7f11-4109-9a19-4e20c0fa4662" {
  name        = "opendevstack-second-development-second-dev"
  description = "Infrastructure repository for project second-development of customer opendevstack."

  gitignore_template = "Terraform"
  auto_init          = true

  visibility = "private"
  # We would like to use a template, but this is currently not supported for GitHub App Installations
  # See https://docs.github.com/en/rest/reference/repos#create-a-repository-using-a-template
  # Workaround: Create files main.tf and .github/workflow/pipeline.yml manually (see gcp_integration terraform template)
}

moved {
  from = github_repository.managed
  to   = github_repository.managed_729d125a-7f11-4109-9a19-4e20c0fa4662
}
