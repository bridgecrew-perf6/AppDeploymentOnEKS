resource "kubernetes_service" "nginx" {
  metadata {
    name = "dinipere-service"
  }
  spec {
    selector = {
      App = "weather-app"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}