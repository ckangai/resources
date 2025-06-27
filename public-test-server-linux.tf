# Create Test Server in Public VPC
resource "google_compute_instance" "test-server-linux" {
  name         = "public-test-server-linux-${random_id.instance_id.hex}"
  machine_type = "f1-micro"
  zone         = var.gcp_zone_1
  tags         = ["allow-ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y python3-pip
    pip3 install apache-beam[GCP]
    pip3 install google-cloud-bigquery
  EOF

  network_interface {
    network        = google_compute_network.public-vpc.name
    subnetwork     = google_compute_subnetwork.public-subnet_1.name
    access_config { } 
  }
} 


output "test-server-linux" {
  value = google_compute_instance.test-server-linux.name
}

output "test-server-linux-external-ip" {
  value = google_compute_instance.test-server-linux.network_interface.0.access_config.0.nat_ip
}

output "test-server-linux-internal-ip" {
  value = google_compute_instance.test-server-linux.network_interface.0.network_ip
}
