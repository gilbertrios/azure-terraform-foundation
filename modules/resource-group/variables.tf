variable "name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where the resource group will be created"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "hello-world"
}

variable "additional_tags" {
  description = "Additional tags to apply to the resource group"
  type        = map(string)
  default     = {}
}

variable "enable_lock" {
  description = "Enable resource lock to prevent accidental deletion"
  type        = bool
  default     = false
}