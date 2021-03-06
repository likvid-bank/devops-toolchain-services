module "github_repo" {
  source = "./modules/service"

  instances_dir         = "./instances"
  service_definition_id = local.service_definition_ids.github_repo
}

resource "local_file" "github_repo" {
  for_each = module.github_repo.instances.not_deleted

  content = templatefile("./templates/resources.github_repo.tftpl", {
    parameters   = each.value.parameters
    instance = jsonencode(each.value)
  })
  filename = "./customers/${each.value.context.customer_id}/projects/${each.value.context.project_id}/resources.github_repo.${each.key}.tf"
}

resource "local_file" "gcp_integration" {
  for_each = module.github_repo.bindings.gcp.not_deleted

  content = templatefile("./templates/resources.github_repo.gcp_integration.tftpl", {
    parameters   = module.github_repo.instances.all[each.value.serviceInstanceId].parameters
    binding = jsonencode(each.value)
  })
  filename = "./customers/${each.value.context.customer_id}/projects/${each.value.context.project_id}/resources.github_repo.gcp_integration.${each.key}.tf"
}

resource "local_file" "azure_integration" {
  for_each = module.github_repo.bindings.azure.not_deleted

  content = templatefile("./templates/resources.github_repo.azure_integration.tftpl", {
    parameters   = module.github_repo.instances.all[each.value.serviceInstanceId].parameters
    binding = jsonencode(each.value)
  })
  filename = "./customers/${each.value.context.customer_id}/projects/${each.value.context.project_id}/resources.github_repo.azure_integration.${each.key}.tf"
}
