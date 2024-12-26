
# Todo Loki 설치 예정

resource "helm_release" "loki" {
  name             = "loki"
  create_namespace = true
  namespace        = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  values = [
    templatefile("${path.module}/loki-values.yaml", {
        loki_arn    = var.loki_arn
        loki_bucket = var.loki_bucket
      }
    )
  ]
}

resource "helm_release" "promtail" {
  name             = "promtail"
  namespace        = "kube-system"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "promtail"
  values = [
    templatefile("${path.module}/promtail-values.yaml", {

      }
    )
  ]
}
