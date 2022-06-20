variable "instances_dir" {
  type        = string
  description = "The path to the instances directory"
}

variable "instance" {
  nullable = true
  default  = null
}

variable "binding" {
  nullable = true
  default  = null
}

variable "success" {
  type = bool
}

variable "description" {
  default = ""
}

resource "local_file" "instance_status" {
  count    = var.instance != null ? 1 : 0
  filename = "${var.instances_dir}/${var.instance.serviceInstanceId}/status.yml"

  content = yamlencode({
    "status" : var.success ? "succeeded" : "failed",
    "description" : var.description
  })
}

resource "local_file" "binding_status" {
  count    = var.binding != null ? 1 : 0
  filename = "${var.instances_dir}/${var.binding.serviceInstanceId}/bindings/${var.binding.bindingId}/status.yml"

  content = yamlencode({
    "status" : var.success ? "succeeded" : "failed",
    "description" : var.description
  })
}
