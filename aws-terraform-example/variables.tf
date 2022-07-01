variable "access_key" {
  type      = string
  sensitive = true

  validation {
    condition     = var.access_key != null
    error_message = "The access key has not been provided in the variables"
  }
}

variable "secret_key" {
  type      = string
  sensitive = true

  validation {
    condition     = var.secret_key != null
    error_message = "The secret key value has not been provided in the variables"
  }
}

variable "region" {
  type      = string
  sensitive = true

  validation {
    condition     = var.region != null
    error_message = "The region has not been specified on the variables"
  }
}

variable "project_name" {
  type = string
  sensitive = true
}

variable "stage_name" {
  type = string
  sensitive = true
  default = "dev"
}