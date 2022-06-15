output "vm_public_ip" {
  value = google_compute_address.static.address
}