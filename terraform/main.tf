# 1. Registramos tu clave pública SSH en DigitalOcean para poder entrar sin contraseña
resource "digitalocean_ssh_key" "default" {
  name       = var.ssh_key_name
  public_key = file(pathexpand(var.ssh_public_key_path))
}

# 2. Creamos la máquina virtual (Droplet)
resource "digitalocean_droplet" "web" {
  name     = "node-service-server"
  region   = var.region
  size     = var.droplet_size
  image    = var.droplet_image
  ssh_keys = [digitalocean_ssh_key.default.id]

  # Etiquetas para organizar y filtrar recursos en DigitalOcean
  tags = ["node-service", "devops", "roadmap-sh"]

  # Esperamos a que el servidor esté listo
  lifecycle {
    create_before_destroy = true
  }
}
