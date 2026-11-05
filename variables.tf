variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Central India"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "hubspoke"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "name_suffix" {
  description = "Unique suffix for resource names"
  type        = string
}

variable "hub_address_space" {
  description = "Hub VNet address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "spoke_address_space" {
  description = "Spoke VNet address space"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "hub_subnet_prefix" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}

variable "spoke_pe_subnet_prefix" {
  type    = list(string)
  default = ["10.1.1.0/24"]
}

variable "common_tags" {
  description = "Tags applied to Azure resources"
  type        = map(string)

  default = {
    Project     = "Hub-Spoke"
    Environment = "Development"
    ManagedBy   = "Terraform"
    Owner       = "Ranjeet"
  }
}