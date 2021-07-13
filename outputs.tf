output "jupyterhub_ip" {
    value = google_compute_instance.jupyterhub.network_interface.0.access_config.0.nat_ip
}
