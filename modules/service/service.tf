variable "service_definition_id" {
  description = "Filter the service by service definition ids."
}

variable "instances_dir" {
  type        = string
  description = "The path to the instances directory"
}

module "instances" {
  source = "../instances"

  instances_dir         = "./instances"
  service_definition_ids = { "service" = var.service_definition_id }
}

module "bindings" {
  source = "../bindings"

  instances_dir         = "./instances"
  service_definition_ids =  { "service" = var.service_definition_id }
}

output "instances" {
  value = module.instances
}

output "bindings" {
  value = module.bindings
}