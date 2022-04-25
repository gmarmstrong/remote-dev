# Variables docs: https://www.packer.io/docs/templates/hcl_templates/variables
variable "gcp_project_id" {
  type = string
}

variable "base_repo" {
  type = string
  description = "URL of your remote-dev git repository"
}

variable "base_dir" {
  type = string
  default = "remote-dev"
  description = "Directory name for base_repo"
}

variable "base_branch" {
  type = string
  default = "main"
  description = "Branch name for branch_repo (e.g., main or master)"
}

variable "dotfiles_repo" {
  type = string
  description = "URL of your dotfiles git repository"
}

variable "dotfiles_dir" {
  type = string
  default = "dotfiles"
  description = "Directory name for the dotfiles_repo"
}

variable "dotfiles_branch" {
  type = string
  default = "main"
  description = "Branch name for branch_repo (e.g., main or master)"
}

variable "dotfiles_script" {
  type = string
  default = "bootstrap.sh"
  description = "Dotfiles setup script (relative path from dotfiles_dir)"
}

variable "ssh_username" {
  type    = string
  description = "See also Terraform variable: ssh_user"
}

variable "gce_zone" {
  type    = string
  default = "us-east1-b"
  description = "See also Terraform variables: region and zone"
}

variable "name" {
  type    = string
  default = "remote-dev"
  description = "Used to name and tag generated image, image family, etc."
}

variable "gce_source_image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

variable "gce_source_image_project_id" {
  type    = []string
  default = [ "ubuntu-os-cloud" ]
}

# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }
