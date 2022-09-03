variable "hcloud_token" {
  type = string
  sensitive = true
}

variable "server_name" {
  type        = string
  default     = "mc-hetzner"
  description = "Name of the server."
}

variable "server_image" {
  type        = string
  default     = "ubuntu-22.04"
  description = "Image for the server."
}

variable "server_type" {
  type        = string
  default     = "cx21"
  description = "The type of server to deploy."
}

variable "server_location" {
  type        = string
  default     = "nbg1"
  description = "The location to deploy the server."
}
