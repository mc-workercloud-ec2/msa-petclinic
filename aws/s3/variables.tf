

variable "s3_endpoint" {
  description = "s3_endpoint name"
  type        = string
}

variable "environment" {
  description = "Runtime Environment such as default, develop, stage, production"
  type        = string

}

variable "oidc" {
  type        = string
}

variable "oidc_arn" {
  type        = string
}