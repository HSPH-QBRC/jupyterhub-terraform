variable "project_id" {
  description = "GCP project ID"
}

variable "credentials_file" {
  description = "Path to JSON file with GCP service account key"
}

variable "region" {
  default = "us-east4"
}

variable "zone" {
  default = "us-east4-c"
}

variable "jupyterhub_machine_config" {
  type    = object({
                machine_type   = string
                disk_size_gb   = number
            })
}

variable "jupyterhub_os_image" {
    default = "ubuntu-2004-focal-v20210325"
}
