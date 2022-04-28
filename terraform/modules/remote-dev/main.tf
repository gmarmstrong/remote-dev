# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A DEVELOPMENT INSTANCE ACCESSIBLE VIA SSH AND MOSH
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# CREATE DEVELOPMENT INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

data "google_compute_default_service_account" "default" {}

data "google_compute_image" "this" {
  family  = "remote-dev"
  project = var.project
}

resource "google_compute_instance" "this" {
  name         = "remote-dev"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.this.name
    }
  }

  network_interface {
    network = "default"
  }

  allow_stopping_for_update = true

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  metadata = {
    ssh-keys               = "${var.ssh_user}:${var.ssh_pub_key}"
    block-project-ssh-keys = true
  }

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = [ "cloud-platform" ]
  }

  tags = ["remote-dev"]

  labels = {
    managed-by = "terraform"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE NETWORK RESOURCES
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_firewall" "ingress" {
  name    = "ingress"
  network = "default"

  direction     = "INGRESS"
  source_ranges = var.source_ranges
  target_tags   = ["remote-dev"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "udp"
    ports    = ["60000-61000"] # TODO needed?
  }
}

resource "google_compute_firewall" "egress" {
  name    = "egress"
  network = "default"

  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["remote-dev"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_address" "ephemeral_external" {
  name = "ephemeral-external"
  description = "Ephemeral external IP address for the remote development server."

  address_type = "EXTERNAL"
  network_tier = "STANDARD"
}
