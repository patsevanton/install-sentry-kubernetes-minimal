module "db" {
  source = "git::https://github.com/terraform-yc-modules/terraform-yc-postgresql.git"

  folder_id  = "xxxx"
  network_id = "xxxx"
  name       = "sentry-postgresql"

  hosts_definition = [
    {
      zone             = "ru-central1-a"
      assign_public_ip = true
      subnet_id        = "xxxx"
    }
  ]

  postgresql_config = {
    max_connections = 395
  }

  databases = [
    {
      name       = "sentry"
      owner      = "sentry"
      lc_collate = "ru_RU.UTF-8"
      lc_type    = "ru_RU.UTF-8"
      extensions = ["citext"]
    }
  ]

  owners = [
    {
      name     = "sentry"
      password = "sentry-postgresql-password"
    }
  ]
}

output "fqdn_database" {
  value     = "c-${module.db.cluster_id}.rw.mdb.yandexcloud.net"
  sensitive = false
}

output "owners_data" {
  description = "List of owners with passwords."
  sensitive   = true
  value       = module.db.owners_data
}

output "databases" {
  description = "List of databases names."
  value       = module.db.databases
}
