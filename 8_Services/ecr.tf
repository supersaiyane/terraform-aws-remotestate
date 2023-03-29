########################################################
#Local block
########################################################

locals {
  project_family = "pfv3stageECR"
  repositories = {
    "pf-auth-service" = {
      image_tag_mutability  = "IMMUTABLE"
      scan_on_push          = true
      #expiration_after_days = 7
      environment           = "dev"
      tags = {
        Project     = "pfv3stage"
        Owner       = "Vertisystem PVT. LTD"
        Description = "pf-auth-service docker image"
      }
    }

    "pf-frontend-service" = {
      image_tag_mutability  = "IMMUTABLE"
      scan_on_push          = true
      #expiration_after_days = 3
      environment           = "stage"

      tags = {
        Project     = "pfv3stage"
        Owner       = "Vertisystem PVT. LTD"
        Description = "pf-auth-service docker image"
      }
    }

    "pf-backend-service" = {
      image_tag_mutability  = "IMMUTABLE"
      scan_on_push          = true
      environment           = "stage"
      #expiration_after_days = 0 # no expiration policy set
      tags = {
        Project     = "pfv3stage"
        Owner       = "Vertisystem PVT. LTD"
        Description = "pf-auth-service docker image"
      }
    }
  }
}

########################################################
# Module block
########################################################


#multiple repo
module "ecr" {
  source   = "./ecr/"
  for_each = local.repositories

  name                  = each.key
  project_family        = local.project_family
  environment           = each.value.environment
  image_tag_mutability  = each.value.image_tag_mutability
  scan_on_push          = each.value.scan_on_push
  #expiration_after_days = each.value.expiration_after_days
  additional_tags       = each.value.tags

}

# single ecr
# module "ecr" {
#   source = "./modules/ecr"
  #   "pf-backend-service" = {
  #     image_tag_mutability  = "IMMUTABLE"
  #     scan_on_push          = true
  #     environment           = "stage"
  #     #expiration_after_days = 0 # no expiration policy set
  #     tags = {
  #       Project     = "pfv3stage"
  #       Owner       = "Vertisystem PVT. LTD"
  #       Description = "pf-auth-service docker image"
  #     }
  #   }
  # }
# }