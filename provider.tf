variable "tokenfile" {
    type = string
    default = "/Users/sanderhoyvik/Keys/dotoken"
}

variable "privatekey" {
    type = "string"
    default = "/Users/sanderhoyvik/Keys/digitalocean"
}

provider "digitalocean" {
  token = "${replace(file(var.tokenfile),"\n","")}"
}
