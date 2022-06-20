variable "service_definition_ids" {
  type = map(string)
  description = "Filter the instances by service definition ids."
}

variable "instances_dir" {
  type        = string
  description = "The path to the instances directory."
}

locals {
  all_instances_in_repository = [for i in fileset(var.instances_dir, "**/instance.yml") : yamldecode(replace(file("${var.instances_dir}/${i}"), "!<PlatformContext>", ""))]
}

locals {
  all = {
    for instance in local.all_instances_in_repository : instance.serviceInstanceId => instance if contains(values(var.service_definition_ids), instance.serviceDefinitionId )
  }

  deleted = {
    for id, instance in local.all : id => instance if instance.deleted
  }

  not_deleted = {
    for id, instance in local.all : id => instance if !instance.deleted
  }
}

locals {
  projects_and_customers = distinct([
    for id, instance in local.all : jsonencode([ instance.context.project_id, instance.context.customer_id])
  ])
}

output "projects_to_customer" {
  value = {
    for p_c in local.projects_and_customers : jsondecode(p_c)[0] => jsondecode(p_c)[1] 
  }
}

output "all" {
  value = local.all
}

output "deleted" {
  value = local.deleted
}

output "not_deleted" {
  value = local.not_deleted
}
