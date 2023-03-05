# Input Variables - Placeholder file
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type = string
  default = "us-east-1"  
}
# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type = string
  default = "stage"
}
# Business Division
variable "business_divsion" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type = string
  default = "technology"
}

variable "s3_bucket_names" {
  type = list
  default = ["dev-bucketewrewrewr.app", "uat-bucketwerewrwer.app", "prod-bucketwerwerewrw.app"]
}