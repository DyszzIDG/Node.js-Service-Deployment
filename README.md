# Implementación del servicio Node.js (DevOps CI/CD Pipeline)

Este proyecto implementa una solución completa de **DevOps y CI/CD** para desplegar un microservicio Node.js en un servidor en la nube (DigitalOcean Droplet / VPS Linux) en el **puerto 80**.

El flujo integra:
* **Node.js + Express**: Servicio web con endpoint `/` que responde `"Hello, world!"` y `/health` para chequeos de salud.
* **Terraform (IaC)**: Aprovisionamiento automatizado de la máquina virtual y claves SSH.
* **Ansible (Configuration Management)**: Configuración del servidor, instalación de Node.js, dependencias y servicio en segundo plano con `systemd`.
* **GitHub Actions (CI/CD)**: Pipeline automatizado de tests y despliegue continuo.

---

## 📁 Estructura del Proyecto

```text
├── .github/
│   └── workflows/
│       ├── deploy-ansible.yml      # Opción 1: Despliegue con Ansible en GitHub Actions
│       └── deploy-ssh.yml          # Opción 2: Despliegue vía SSH directo (appleboy/ssh-action)
├── ansible/
│   ├── ansible.cfg                 # Configuración de Ansible
│   ├── inventory.ini               # Inventario de servidores
│   ├── node_service.yml            # Playbook principal de Ansible
│   └── roles/
│       └── app/
│           ├── defaults/main.yml   # Variables por defecto (puerto 80, rutas, versión)
│           ├── handlers/main.yml   # Handler para reiniciar el servicio systemd
│           ├── tasks/main.yml      # Tareas (instalación Node, git clone, npm install, systemd)
│           └── templates/
│               └── node_service.service.j2  # Template systemd para ejecución continua
├── src/
│   └── server.js                   # Aplicación Express (puerto 80, ruta /, /health)
├── test/
│   └── server.test.js              # Tests automatizados nativos (node --test)
├── terraform/
│   ├── main.tf                     # Definición de recursos (Droplet + SSH Key)
│   ├── outputs.tf                  # IP pública y comando SSH de salida
│   ├── provider.tf                 # Configuración del proveedor DigitalOcean
│   ├── terraform.tfvars.example    # Ejemplo de variables requeridas
│   └── variables.tf                # Definición de variables configurables
├── .gitignore                      # Exclusiones de Git (node_modules, tfstate, etc.)
├── node_service.yml                # Enlace directo al playbook de Ansible en la raíz
├── package.json                    # Dependencias y scripts de Node.js
└── README.md                       # Documentación completa del proyecto
```

---

## 🧪 1. Prueba Local de la Aplicación

Para verificar que el servicio Node.js funciona correctamente en tu máquina:

```bash
# 1. Instalar dependencias
npm install

# 2. Ejecutar las pruebas automáticas
npm test

# 3. Iniciar el servidor localmente (en puerto 3000 o el que desees)
PORT=3000 npm start
```

Prueba en tu navegador o terminal:
* `http://localhost:3000/` ➔ `"Hello, world!"`
* `http://localhost:3000/health` ➔ `{"status":"ok","uptime":...}`

---

## 🏗️ 2. Aprovisionar Servidor con Terraform (IaC)

1. Dirígete a la carpeta `terraform/`:
   ```bash
   cd terraform
   ```

2. Crea tu archivo de variables locales a partir de la plantilla:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   Edita `terraform.tfvars` con tu token de DigitalOcean (`do_token`) y la ruta a tu clave pública SSH (`~/.ssh/id_ed25519.pub` o `~/.ssh/id_rsa.pub`).

3. Inicializa y aplica la infraestructura:
   ```bash
   terraform init
   terraform plan
   terraform apply -auto-approve
   ```

4. Terraform imprimirá la **IP pública** del servidor (`droplet_ip`). Anótala para el siguiente paso.

---

## 🛠️ 3. Configuración y Despliegue Manual con Ansible

Una vez que el servidor está en línea:

1. Edita `ansible/inventory.ini` y coloca la IP pública del servidor:
   ```ini
   [web]
   servidor_node ansible_host=<IP_PUBLICA_DEL_SERVIDOR> ansible_user=root
   ```

2. Ejecuta el playbook con el tag `app` tal como lo requiere el proyecto:
   ```bash
   ansible-playbook node_service.yml --tags app
   ```

3. **Verificación en el navegador**:
   Abre en tu navegador la IP pública de tu servidor:
   * `http://<IP_PUBLICA>/` ➔ Deberás ver **"Hello, world!"** en el puerto 80.
   * `http://<IP_PUBLICA>/health` ➔ `{"status":"ok"}`.

---

## 🤖 4. Automatización con GitHub Actions (CI/CD)

Cada vez que hagas `git push` a la rama `main`, GitHub Actions se encargará de ejecutar los tests y desplegar la nueva versión.

### Configuración de Secretos en GitHub
En tu repositorio de GitHub, ve a **Settings** ➔ **Secrets and variables** ➔ **Actions** ➔ **New repository secret** y añade:

| Nombre del Secreto | Descripción | Ejemplo |
| :--- | :--- | :--- |
| `SERVER_HOST` | Dirección IP pública del servidor | `159.65.123.45` |
| `SERVER_USER` | Usuario SSH para la conexión | `root` |
| `SSH_PRIVATE_KEY` | Clave SSH privada correspondiente a la clave pública registrada en el servidor | `-----BEGIN OPENSSH PRIVATE KEY----- ...` |

### Opciones de Despliegue Disponibles
1. **Opción #1 (Recomendada): `.github/workflows/deploy-ansible.yml`**
   * Corre automáticamente al hacer `push` a `main`.
   * Ejecuta `npm test`.
   * Instala Ansible en el runner, monta la clave SSH usando `webfactory/ssh-agent` y corre `ansible-playbook node_service.yml --tags app`.
   * Verifica automáticamente la respuesta HTTP en `/health`.

2. **Opción #2: `.github/workflows/deploy-ssh.yml`**
   * Utiliza la acción `appleboy/ssh-action` para conectarse por SSH al servidor, hacer `git pull`, `npm install --omit=dev` y reiniciar el servicio `systemctl restart node_service`.
