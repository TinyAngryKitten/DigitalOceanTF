data "digitalocean_volume" "devserver" {
  region = "lon1"
  name = "applicationdata"
}

resource "digitalocean_droplet" "devserver" {
    image = "docker-18-04"
    name = "devserver"
    region = "lon1"
    size = "s-1vcpu-1gb"
    monitoring = true
    resize_disk = false
    private_networking = true
    ssh_keys = [
      "26:8b:ac:ad:c9:5e:a9:48:49:b4:76:d8:bc:c4:f7:cd",
      "fe:cc:13:74:b8:d4:3a:08:d1:2b:a3:fb:00:aa:c2:72"
    ]

  provisioner "file" {
   source      = "scripts/startdockercontainers.sh"
   destination = "/root/startcontainers.sh"
  }

connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.privatekey)}"
      timeout = "2m"
  }

provisioner "remote-exec" {
    scripts = [
      "scripts/init.sh",
    ]
  }
}

resource "digitalocean_volume_attachment" "devserver" {
  droplet_id = "${digitalocean_droplet.devserver.id}"
  volume_id  = "${data.digitalocean_volume.devserver.id}"
}

resource "digitalocean_floating_ip" "devserver" {
  droplet_id = "${digitalocean_droplet.devserver.id}"
  region     = "${digitalocean_droplet.devserver.region}"
}

resource "digitalocean_firewall" "devserver" {
  name = "devserverfw"

  droplet_ids = ["${digitalocean_droplet.devserver.id}"]

  inbound_rule = [
    {
      protocol           = "tcp"
      port_range         = "22"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol           = "tcp"
      port_range         = "6666"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol           = "tcp"
      port_range         = "8081"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol           = "icmp"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
  ]

  outbound_rule = [
    {
      protocol                = "tcp"
      port_range              = "1-65535"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol                = "udp"
      port_range              = "1-65535"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol                = "icmp"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
  ]
}
