module "s3" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-storage-bucket.git?ref=v1.0.0"

  bucket_name = "sentry-bucket-apatsev-dev"
  folder_id   = "xxxx"
}

provider "aws" {
  region                      = "us-east-1"
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

output "access_key" {
  value = module.s3.storage_admin_access_key
}

output "secret_key" {
  value     = module.s3.storage_admin_secret_key
  sensitive = true
}
