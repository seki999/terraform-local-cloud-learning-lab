terraform {
  required_version = ">= 1.6.0"
}

variable "listen_address" {
  description = "Host address used by the local security lab."
  type        = string
  default     = "127.0.0.1"

  validation {
    condition     = var.listen_address == "127.0.0.1"
    error_message = "This local lab must remain bound to loopback."
  }
}

variable "publish_admin_endpoint" {
  description = "Teaching guardrail: the admin endpoint must not be published."
  type        = bool
  default     = false

  validation {
    condition     = var.publish_admin_endpoint == false
    error_message = "The admin endpoint must remain private in this lab."
  }
}

check "local_security_boundary" {
  assert {
    condition     = var.listen_address == "127.0.0.1" && !var.publish_admin_endpoint
    error_message = "Local security boundary validation failed."
  }
}

output "security_boundary" {
  value = {
    listen_address         = var.listen_address
    publish_admin_endpoint = var.publish_admin_endpoint
  }
}
