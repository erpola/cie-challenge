variable "subscription_id" {
  type        = string
  description = "Subscription ID"
}

variable "project_name" {
  type        = string
  description = "Project Name"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "location" {
  type        = string
  description = "Location"
}

variable "virtual_network_config" {
  type = object({
    base_cidr    = string
    subnet_count = number
  })

  description = "The configuration for the virtual network."
  validation {
    condition     = var.virtual_network_config.subnet_count >= 3
    error_message = "Subnet count must be at least 3."
  }

}