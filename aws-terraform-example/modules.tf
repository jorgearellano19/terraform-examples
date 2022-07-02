module "app" {
  source = "./modules/app"
  composite_name = local.composite_name
  client_cdn_origin_id = local.client_cdn_origin_id
}

module "api" {
  source = "./modules/api"
  composite_name = local.composite_name
  composite_name_upper = local.composite_name_upper
  stage_name = var.stage_name
  project_name = var.project_name
  aws_region = var.region
}