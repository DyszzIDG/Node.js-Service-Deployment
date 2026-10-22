output "droplet_ip" {
  description = "Dirección IPv4 pública asignada al servidor"
  value       = digitalocean_droplet.web.ipv4_address
}

output "ssh_command" {
  description = "Comando para conectarte rápidamente al servidor por SSH"
  value       = "ssh root@${digitalocean_droplet.web.ipv4_address}"
}
