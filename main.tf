terraform {
  required_version = "~> 0.14.8"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.60.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}


resource "google_compute_network" "jupyterhub_network" {
    name           = "jupyterhub-network"    
}

# Allow http/s and ssh into that machine
resource "google_compute_firewall" "jupyterhub_firewll" {
  name    = "jupyter-firewall"
  network = google_compute_network.jupyterhub_network.name

  allow {
    protocol                 = "tcp"
    ports                    = ["80", "443", "22"]
  }

  target_tags = ["jupyterhub-firewall"]
}

resource "random_id" "instance_name_suffix" {
  byte_length = 4
}

resource "google_compute_instance" "jupyterhub" {
  name                    = "jupyterhub-${random_id.instance_name_suffix.hex}"
  machine_type            = var.jupyterhub_machine_config.machine_type
  tags                    = ["jupyterhub-firewall"]


  metadata_startup_script = templatefile("jupyterhub_provision.sh", 
    { 
    }
  )

  boot_disk {
    initialize_params {
      image = var.jupyterhub_os_image
      size = var.jupyterhub_machine_config.disk_size_gb
    }
  }

  network_interface {
    network = google_compute_network.jupyterhub_network.name
    access_config {
      // creates a public IP
    }
  }
}
