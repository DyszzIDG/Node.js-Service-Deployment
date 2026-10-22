terraform {
  required_version = ">= 1.0.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.34"
    }
  }
}

# Configuramos el proveedor de DigitalOcean usando el token de acceso
provider "digitalocean" {
  token = var.do_token
}
