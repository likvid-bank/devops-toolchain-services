variable "service_definition_ids" {
  type        = map(string)
  description = "Filter the bindings by service definition ids."
}

variable "instances_dir" {
  type        = string
  description = "The path to the instances directory."
}

locals {
  binding_ymls               = fileset(var.instances_dir, "/**/bindings/**/binding.yml")
  all_bindings_in_repository = [for i in local.binding_ymls : yamldecode(replace(file("${var.instances_dir}/${i}"), "!<PlatformContext>", ""))]
}

locals {
  all = {
    for binding in local.all_bindings_in_repository : binding.bindingId => binding
    if contains(values(var.service_definition_ids), binding.serviceDefinitionId)
  }
  gcp = {
    for id, binding in local.all : id => binding if binding.bindResource.platform == "gcp.gcp-meshstack-dev" # TODO configure
  }
  azure = {
    for id, binding in local.all : id => binding if binding.bindResource.platform == "azure.azure" # TODO configure
  }
}

output "all" {
  value = local.all
}


module "instances" {
  source = "../instances"

  instances_dir          = var.instances_dir
  service_definition_ids = var.service_definition_ids
}

output "deleted" {
  value = {
    for id, binding in local.all : id => binding if binding.deleted || contains(keys(module.instances.deleted), binding.serviceInstanceId)
  }
  description = "Bindings that are deleted. If the parent instance of a binding is deleted, it counts as deleted, regardless of it's own deleted flag."
}

output "not_deleted" {
  value = {
    for id, binding in local.all : id => binding if !binding.deleted && contains(keys(module.instances.not_deleted), binding.serviceInstanceId)
  }
  description = "Bindings that are not deleted. If the parent instance of a binding is deleted, it counts as deleted, regardless of it's own deleted flag."
}

output "azure" {
  value = {
    all = local.azure,
    not_deleted = {
      for id, binding in local.azure : id => binding if !binding.deleted && contains(keys(module.instances.not_deleted), binding.serviceInstanceId)
    }

  }
}

output "gcp" {
  value = {
    all = local.gcp,
    not_deleted = {
      for id, binding in local.gcp : id => binding if !binding.deleted && contains(keys(module.instances.not_deleted), binding.serviceInstanceId)
    }
  }
}
