module "redis" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-redis.git?ref=v1.0.0"

  folder_id  = "xxxx"
  name       = "sentry-redis"
  network_id = "xxxxx"
  password   = "sentry-redis-password"
  zone       = "ru-central1-a"
  hosts = {
    host1 = {
      zone      = "ru-central1-a"
      subnet_id = "xxxxx"
    }
  }
}

output "password" {
  value     = module.redis.password
  sensitive = true
}

output "fqdn_redis" {
  value = module.redis.fqdn_redis
}
