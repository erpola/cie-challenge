locals {
  suffix   = lower("${var.project_name}-${var.environment}-${var.location}")
  hex      = random_bytes.random.hex
  vm_count = 2
  tags = {
    environment = var.environment
    project     = var.project_name
    location    = var.location
  }
}