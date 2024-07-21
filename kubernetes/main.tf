module "iam_accounts" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-iam.git//modules/iam-account?ref=v1.0.0"

  name = "iam-sentry-kubernetes"
  folder_roles = [
    "container-registry.images.puller",
    "k8s.clusters.agent",
    "k8s.tunnelClusters.agent",
    "load-balancer.admin",
    "logging.writer",
    "vpc.privateAdmin",
    "vpc.publicAdmin",
    "vpc.user",
  ]
  folder_id = "xxxx"

}

module "kube" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-kubernetes.git?ref=v1.1.0"

  folder_id  = "xxxx"
  network_id = "xxxx"

  name = "k8s-sentry"

  service_account_id      = module.iam_accounts.id
  node_service_account_id = module.iam_accounts.id

  master_locations = [
    {
      zone      = "ru-central1-a"
      subnet_id = "xxxx"
    }
  ]

  node_groups = {
    "auto-scale" = {
      nat    = true
      cores  = 6
      memory = 12
      auto_scale = {
        min     = 4
        max     = 6
        initial = 4
      }
    }
  }

  depends_on = [module.iam_accounts]

}

module "address" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-address.git?ref=v1.0.0"

  ip_address_name = "sentry-pip"
  folder_id       = "xxxx"
  zone            = "ru-central1-a"
}

module "dns-zone" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-dns.git//modules/zone?ref=v1.0.0"

  folder_id = "xxxx"
  name      = "apatsev-org-ru-zone"

  zone             = "apatsev.org.ru." # Точка в конце обязательна
  is_public        = true
  private_networks = ["xxxx"] # network_id
}

module "dns-recordset" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-dns.git//modules/recordset?ref=v1.0.0"

  folder_id = "xxxx"
  zone_id   = module.dns-zone.id
  name      = "sentry.apatsev.org.ru." # Точка в конце обязательна
  type      = "A"
  ttl       = 200
  data = [
    module.address.external_ipv4_address
  ]
}

provider "helm" {
  kubernetes {
    host                   = module.kube.external_v4_endpoint
    cluster_ca_certificate = module.kube.cluster_ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["k8s", "create-token"]
      command     = "yc"
    }
  }
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.10.1"
  namespace        = "ingress-nginx"
  create_namespace = true
  depends_on       = [module.kube]
  set {
    name  = "controller.service.loadBalancerIP"
    value = module.address.external_ipv4_address
  }

}
