variable "tokenfile" {
    type = "string"
    default = "/Users/sander/Keys/dotoken"
}

variable "privatekey" {
    type = "string"
    default = "/Users/sander/Keys/digitalocean"
}

provider "digitalocean" {
  token = "${replace(file(var.tokenfile),"\n","")}"
}
