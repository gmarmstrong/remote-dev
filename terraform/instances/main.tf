# Backend configuration

terraform {
  required_version = ">= 0.12, < 0.13"

  backend "gcs" {
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_name
  region  = var.region
}

data "google_compute_image" "remote_dev_image" {
  family  = "remote-dev"
  project = var.project_name
}

# Instance configuration

resource "google_compute_instance" "remote_dev" {
  name         = "remote-dev"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.remote_dev_image.name
    }
  }

  network_interface {
    network = google_compute_network.public.name

    access_config {
      nat_ip = google_compute_address.static_external.address
    }
  }

  allow_stopping_for_update = true

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/logging.read",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }

  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file("${path.module}/${var.gce_ssh_pub_key_file}")}"
  }

  tags = ["public-ssh-access"]
}

# Network configuration

resource "google_compute_network" "public" {
  name        = "public"
  description = "Public-facing network."

  routing_mode = "REGIONAL"
}

resource "google_compute_subnetwork" "public" {
  name   = "public-subnetwork"
  region = var.region

  network       = google_compute_network.public.self_link
  ip_cidr_range = "10.0.0.0/24"
}

resource "google_compute_firewall" "public_ssh" {
  name    = "public-ssh"
  network = google_compute_network.public.name

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["public-ssh-access"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "udp"
    ports    = ["60000-60010"]
  }
}

resource "google_compute_address" "static_external" {
  name         = "static-external"
  description  = "Static external IP address for the remote development server."
  address_type = "EXTERNAL"
}