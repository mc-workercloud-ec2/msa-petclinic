

variable "bucket_name" {
  description = "s3 bucket name"
  type        = string
}

variable "lock_table_name" {
  description = "dynamo db locking table name"
  type    = string
}
variable "environment" {
  description = "Runtime Environment such as default, develop, stage, production"
  type        = string

}