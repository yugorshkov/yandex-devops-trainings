output "postgres_ip" {
  value = yandex_compute_instance.postgres.network_interface.0.nat_ip_address
}
