#network.tf
resource "yandex_vpc_network" "develop" {
  name = "develop-fops-${var.flow}"
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name               = "fops-gateway-${var.flow}"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "fops-route-table-${var.flow}"
  network_id = yandex_vpc_network.develop.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_vpc_subnet" "develop_a" {
  name           = "develop-fops-${var.flow}-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.1.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_security_group" "cache_server" {
  name       = "cache-server-${var.flow}"
  network_id = yandex_vpc_network.develop.id

  # SSH
  ingress {
    description    = "SSH 0.0.0.0/0"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 22
    to_port        = 22
  }
  
  # Memcahed
  ingress {
    description    = "Memcahed 11211"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 11211
    to_port        = 11211
  }

  # Redis Server
  ingress {
    description    = "Redis 6379"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 6379
    to_port        = 6379
  }

  # Egress полный
  egress {
    description    = "ANY outbound"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

output "security_group_id" {
  value = yandex_vpc_security_group.cache_server.id
}

output "subnets" {
  value = {
    a = yandex_vpc_subnet.develop_a.id
  }
}
