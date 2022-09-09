terraform {
  required_version = ">= 0.14"
    required_providers {
      hcloud = {
        source = "hetznercloud/hcloud"
        version = ">= 1.35.1"
      }
    }
}

provider "hcloud" {
  token = var.hcloud_token
}

# Get public IP address to restrict SSH access on the firewall
data "http" "public_ip" {
  url = "https://api.ipify.org"
}

# Create SSH key to apply to the server
resource "hcloud_ssh_key" "default" {
  name       = "mc-hetzner-ssh-key"
  public_key = file("~/.ssh/mc_hetzner.pub")
}

# Create a firewall to restrict access via SSH and allow Minecraft port 25565
resource "hcloud_firewall" "default" {
  name = "mc-hetzner-firewall"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = ["${chomp(data.http.public_ip.body)}/32"]
  }

  # Minecraft Java edition port rule
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "25565"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Minecraft Bedrock edition port rule
  # Use GeyserMC to allow Bedrock players to play on a Java edition server
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "19132"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

# Create the server
resource "hcloud_server" "mc-hetzner" {
  name        = var.server_name
  image       = var.server_image
  server_type = var.server_type
  location    = var.server_location
  ssh_keys    = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.default.id]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
  labels = {
    "type" : "Minecraft"
  }
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address}' --private-key ~/.ssh/mc_hetzner mc-hetzner.yml"
  }
}
