terraform {
  required_version = ">= 1.1.8"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.0"
    }
  }
}
