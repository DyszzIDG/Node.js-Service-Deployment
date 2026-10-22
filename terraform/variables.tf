variable "do_token" {
  description = "Token de API de DigitalOcean para autenticar la creación de recursos"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Región del centro de datos donde se desplegará el Droplet (ej. nyc1, nyc3, fra1)"
  type        = string
  default     = "nyc1"
}

variable "droplet_size" {
  description = "Tamaño y especificaciones de la máquina virtual (s-1vcpu-1gb es la opción más económica)"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "droplet_image" {
  description = "Distribución del sistema operativo base para el servidor"
  type        = string
  default     = "ubuntu-22-04-x64"
}

variable "ssh_key_name" {
  description = "Nombre que se le dará a la clave SSH en DigitalOcean"
  type        = string
  default     = "node-service-deploy-key"
}

variable "ssh_public_key_path" {
  description = "Ruta al archivo de clave pública SSH local (ej. ~/.ssh/id_rsa.pub o ~/.ssh/id_ed25519.pub)"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
