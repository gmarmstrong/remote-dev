# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "machine_type" {
  type = string

  validation {
    condition = (
      can(regex("[[:alnum:]]+-[[:lower:]]+(?:-[[:digit:]]){0,1}", var.machine_type))
    )
    error_message = "The machine type doesn't have a proper format."
  }
}

variable "project" {
  type = string
}

variable "ssh_pub_key" {
  type = string
}

variable "ssh_user" {
  type = string
}

variable "source_ranges" {
  type = list(string)
  default = "35.235.240.0/20" # the GCP IAP source address range
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "region" {
  type    = string
  default = "us-east1"

  validation {
    condition = (
      can(regex("[[:lower:]]+-[[:lower:]]+[[:digit:]]", var.region))
    )
    error_message = "The region value doesn't have a proper format."
  }
}

variable "zone" {
  type    = string
  default = "us-east1-b"

  validation {
    condition = (
      can(regex("[[:lower:]]+-[[:lower:]]+[[:digit:]]-[[:lower:]]", var.zone))
    )
    error_message = "The zone value doesn't have a proper format."
  }
}
