job "hotel-reservation" {
  datacenters = ["dc1"]
  type        = "service"

  # Infrastructure Group
  group "infrastructure" {
    network {
      port "jaeger_http" {
        static = 16686
        host_network = "private"
      }
    }
    task "jaeger" {
      driver = "docker"
      config {
        image = "jaegertracing/all-in-one:latest"
        ports = ["jaeger_http"]
      }
    }
  }

  # Database Group
  group "databases" {
    network {
      port "mongo_geo" { 
        static = 27017
        host_network = "private" 
      }
      port "mongo_profile" { 
        static = 27018
        host_network = "private" 
      }
      port "mongo_rate" { 
        static = 27019
        host_network = "private" 
      }
      port "mongo_rec" { 
        static = 27020
        host_network = "private" 
      }
      port "mongo_res" { 
        static = 27021
        host_network = "private" 
      }
      port "mongo_user" { 
        static = 27022
        host_network = "private" 
      }
      port "mem_profile" { 
        static = 11211
        host_network = "private" 
      }
      port "mem_rate" { 
        static = 11212
        host_network = "private" 
      }
      port "mem_reserve" { 
        static = 11213
        host_network = "private" 
      }
    }

    task "mongo-geo" {
      driver = "docker"
      config {
        image = "mongo:4.4.6"
        ports = ["mongo_geo"]
      }
      service {
        name = "mongodb-geo"
        port = "mongo_geo"
      }
    }

    task "mongo-profile" {
      driver = "docker"
      config {
        image = "mongo:4.4.6"
        ports = ["mongo_profile"]
      }
      service {
        name = "mongodb-profile"
        port = "mongo_profile"
      }
    }

    task "mongo-rate" {
      driver = "docker"
      config {
        image = "mongo:4.4.6"
        ports = ["mongo_rate"]
      }
      service {
        name = "mongodb-rate"
        port = "mongo_rate"
      }
    }

    task "mongo-recommendation" {
      driver = "docker"
      config {
        image = "mongo:4.4.6"
        ports = ["mongo_rec"]
      }
      service {
        name = "mongodb-recommendation"
        port = "mongo_rec"
      }
    }

    task "mongo-reservation" {
      driver = "docker"
      config {
        image = "mongo:4.4.6"
        ports = ["mongo_res"]
      }
      service {
        name = "mongodb-reservation"
        port = "mongo_res"
      }
    }

    task "mongo-user" {
      driver = "docker"
      config {
        image = "mongo:4.4.6"
        ports = ["mongo_user"]
      }
      service {
        name = "mongodb-user"
        port = "mongo_user"
      }
    }

    task "memcached-profile" {
      driver = "docker"
      config {
        image = "memcached:latest"
        ports = ["mem_profile"]
      }
      service {
        name = "memcached-profile"
        port = "mem_profile"
      }
    }

    task "memcached-rate" {
      driver = "docker"
      config {
        image = "memcached:latest"
        ports = ["mem_rate"]
      }
      service {
        name = "memcached-rate"
        port = "mem_rate"
      }
    }

    task "memcached-reserve" {
      driver = "docker"
      config {
        image = "memcached:latest"
        ports = ["mem_reserve"]
      }
      service {
        name = "memcached-reserve"
        port = "mem_reserve"
      }
    }
  }

  # Microservices Group
  group "app" {
    network {
      port "frontend" {
        static = 5000
        host_network = "private"
        to     = 5000
      }
      port "geo" {
        static = 8083
        host_network = "private"
        to     = 8083
      }
      port "profile" {
        static = 8081
        host_network = "private"
        to     = 8081
      }
      port "rate" {
        static = 8084
        host_network = "private"
        to     = 8084
      }
      port "recommendation" {
        static = 8085
        host_network = "private"
        to     = 8085
      }
      port "reservation" {
        static = 8087
        host_network = "private"
        to     = 8087
      }
      port "search" {
        static = 8082
        host_network = "private"
        to     = 8082
      }
      port "user" {
        static = 8086
        host_network = "private"
        to     = 8086
      }
    }

    task "frontend" {
      driver = "docker"
      config {
        image = "deathstarbench/hotel-reservation:latest"
        entrypoint = ["/go/bin/frontend"]
        ports = ["frontend"]
        extra_hosts = [
          "consul:${attr.unique.network.ip-address}",
          "jaeger:${attr.unique.network.ip-address}"
        ]
      }
      env {
        CONSUL_HTTP_ADDR = "http://${attr.unique.network.ip-address}:8500"
      }
      service {
        name = "frontend"
        port = "frontend"
      }
    }

    task "geo" {
      driver = "docker"
      config {
        image = "deathstarbench/hotel-reservation:latest"
        entrypoint = ["/go/bin/geo"]
        ports = ["geo"]
        extra_hosts = [
          "consul:${attr.unique.network.ip-address}",
          "jaeger:${attr.unique.network.ip-address}"
        ]
      }
      env {
        CONSUL_HTTP_ADDR = "http://${attr.unique.network.ip-address}:8500"
      }
      service {
        name = "geo"
        port = "geo"
      }
    }

    task "profile" {
      driver = "docker"
      config {
        image = "deathstarbench/hotel-reservation:latest"
        entrypoint = ["/go/bin/profile"]
        ports = ["profile"]
        extra_hosts = [
          "consul:${attr.unique.network.ip-address}",
          "jaeger:${attr.unique.network.ip-address}"
        ]
      }
      env {
        CONSUL_HTTP_ADDR = "http://${attr.unique.network.ip-address}:8500"
      }
      service {
        name = "profile"
        port = "profile"
      }
    }

    task "rate" {
      driver = "docker"
      config {
        image = "deathstarbench/hotel-reservation:latest"
        entrypoint = ["/go/bin/rate"]
        ports = ["rate"]
        extra_hosts = [
          "consul:${attr.unique.network.ip-address}",
          "jaeger:${attr.unique.network.ip-address}"
        ]
      }
      env {
        CONSUL_HTTP_ADDR = "http://${attr.unique.network.ip-address}:8500"
      }
      service {
        name = "rate"
        port = "rate"
      }
    }

    task "recommendation" {
      driver = "docker"
      config {
        image = "deathstarbench/hotel-reservation:latest"
        entrypoint = ["/go/bin/recommendation"]
        ports = ["recommendation"]
        extra_hosts = [
          "consul:${attr.unique.network.ip-address}",
          "jaeger:${attr.unique.network.ip-address}"
        ]
      }
      env {
        CONSUL_HTTP_ADDR = "http://${attr.unique.network.ip-address}:8500"
      }
      service {
        name = "recommendation"
        port = "recommendation"
      }
    }

    task "reservation" {
      driver = "docker"
      config {
        image = "deathstarbench/hotel-reservation:latest"
        entrypoint = ["/go/bin/reservation"]
        ports = ["reservation"]
        extra_hosts = [
          "consul:${attr.unique.network.ip-address}",
          "jaeger:${attr.unique.network.ip-address}"
        ]
      }
      env {
        CONSUL_HTTP_ADDR = "http://${attr.unique.network.ip-address}:8500"
      }
      service {
        name = "reservation"
        port = "reservation"
      }
    }

    task "search" {
      driver = "docker"
      config {
        image = "deathstarbench/hotel-reservation:latest"
        entrypoint = ["/go/bin/search"]
        ports = ["search"]
        extra_hosts = [
          "consul:${attr.unique.network.ip-address}",
          "jaeger:${attr.unique.network.ip-address}"
        ]
      }
      env {
        CONSUL_HTTP_ADDR = "http://${attr.unique.network.ip-address}:8500"
      }
      service {
        name = "search"
        port = "search"
      }
    }

    task "user" {
      driver = "docker"
      config {
        image = "deathstarbench/hotel-reservation:latest"
        entrypoint = ["/go/bin/user"]
        ports = ["user"]
        extra_hosts = [
          "consul:${attr.unique.network.ip-address}",
          "jaeger:${attr.unique.network.ip-address}"
        ]
      }
      env {
        CONSUL_HTTP_ADDR = "http://${attr.unique.network.ip-address}:8500"
      }
      service {
        name = "user"
        port = "user"
      }
    }
  }
}
