resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "dinipere-deployment"
    labels = {
      App = "weather-app"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "weather-app"
      }
    }
    template {
      metadata {
        labels = {
          App = "weather-app"
        }
      }
      spec {
        container {
          image = "456131486398.dkr.ecr.us-east-1.amazonaws.com/webapp:latest"
          name  = "prod-con"

          port {
            container_port = 80
          }

          resources {}
        }
      }
    }
  }
}
