job "tfserving-resnet" {
  region      = "global"
  datacenters = ["dc1"]
  type        = "service"

  group "tfserving" {
    count = 3

    network {
      # Ask Nomad to allocate a static port to match our NodePort equivalent
      port "rest" {
        static = 30501
        to     = 8501
      }
      port "grpc" {
        to = 8500
      }
    }

    task "tfserving" {
      driver = "docker"

      config {
        image = "bitnami/tensorflow-serving:latest"
        ports = ["rest", "grpc"]
      }

      env {
        MODEL_NAME      = "resnet"
        MODEL_BASE_PATH = "/models/resnet"
      }

      resources {
        # Limit constraints mirroring the 2GB RAM / 2 vCPU 
        cpu    = 2000 # MHz
        memory = 2048 # MB
      }
    }
  }
}
