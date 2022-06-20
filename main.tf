locals {
  service_definition_ids = {
    github_repo = "E1A838DE-AA9C-4DED-A23C-24824BC1B192"
  }
}

# Work on all instance files
module "instances" {
  source = "./modules/instances"

  instances_dir          = "./instances"
  service_definition_ids = local.service_definition_ids
}

# Always update instance status to "successful" because binding status reflects service status
module "instance_status" {
  source   = "./modules/status"
  for_each = module.instances.all

  instances_dir = "./instances"
  instance      = each.value
  success       = true
  description   = "Updated instance successfully"
}

# Always create a backend per project
resource "local_file" "backend" {
  for_each = module.instances.projects_to_customer

  content = templatefile("./templates/backend.tftpl", {
    mesh_customer = each.value,
    mesh_project  = each.key
  })
  filename = "./customers/${each.value}/projects/${each.key}/backend.tf"
}

# Always create a pipeline per project
resource "local_file" "pipeline" {
  for_each = module.instances.projects_to_customer

  content = templatefile(".github/pipeline.ymltpl", {
    mesh_customer = each.value,
    mesh_project  = each.key
  })
  filename = ".github/workflows/terraform-apply-${each.value}-${each.key}.yml"
}

# If a tenant binding exists, create a provider configuration
# We include deleted bindings to make sure terraform can clean up if necessary
module "bindings" {
  source = "./modules/bindings"

  instances_dir          = "./instances"
  service_definition_ids = local.service_definition_ids
}

resource "local_file" "provider_azurerm" {
  for_each = module.bindings.azure

  content = templatefile("./templates/provider.azurerm.tftpl", {
    subscription = each.value.bindResource.tenant_id
  })
  filename = "./customers/${each.value.context.customer_id}/projects/${each.value.context.project_id}/provider.azurerm.tf"
}
