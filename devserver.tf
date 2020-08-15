resource "digitalocean_droplet" "devserver" {
    image = "docker-18-04"
    name = "devserver"
    region = "lon1"
    size = "s-1vcpu-2gb"
    monitoring = true
    resize_disk = false
    private_networking = true
    ssh_keys = [
      "26:8b:ac:ad:c9:5e:a9:48:49:b4:76:d8:bc:c4:f7:cd",
      "fe:cc:13:74:b8:d4:3a:08:d1:2b:a3:fb:00:aa:c2:72"
    ]
    connection {
          host = self.ipv4_address
          user = "root"
          type = "ssh"
          private_key = "${file(var.privatekey)}"
          timeout = "2m"
      }
  provisioner "file" {
   source      = "configs"
   destination = "/root/configs"
  }
  provisioner "file" {
   source      = "docker-compose.yml"
   destination = "/root/docker-compose.yml"
  }

provisioner "remote-exec" {
    scripts = [
      "scripts/init.sh",
    ]
  }
}

data "digitalocean_volume" "devserver" {
  region = "lon1"
  name = "data"
  initial_filesystem_type = "ext4"
}

resource "digitalocean_floating_ip" "devserver" {
  droplet_id = "${digitalocean_droplet.devserver.id}"
  region     = "${digitalocean_droplet.devserver.region}"
}

resource "digitalocean_firewall" "devserver" {
  name = "devserverfw"

  droplet_ids = ["${digitalocean_droplet.devserver.id}"]

  inbound_rule {
      protocol           = "tcp"
      port_range         = "22"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    }
  inbound_rule {
      protocol           = "tcp"
      port_range         = "1883"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    }
  inbound_rule {
      protocol           = "tcp"
      port_range         = "9001"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    }
  inbound_rule {
      protocol           = "tcp"
      port_range         = "8888"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    }
  inbound_rule {
      protocol           = "tcp"
      port_range         = "8086"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    }
  inbound_rule {
      protocol           = "icmp"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    }

  outbound_rule {
      protocol                = "tcp"
      port_range              = "1-65535"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    }
  outbound_rule {
      protocol                = "udp"
      port_range              = "1-65535"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    }
  outbound_rule {
      protocol                = "icmp"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    }
}
