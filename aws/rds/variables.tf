variable "dbname" {
  description = "DB bucket name"
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
}

variable "dbuser" {
  type    = string
}
variable "dbpassword" {
  type    = string
}

variable "vpc_id" {
  type    = string
}
variable "environment" {
  description = "Runtime Environment such as default, develop, stage, production"
  type        = string

}