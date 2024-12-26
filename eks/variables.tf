


variable "environment" {
  description = "Runtime Environment such as default, develop, stage, production"
  type        = string

}
variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string

}
variable "domain" {
  type = string
}

variable "dbname" {
  type = string
}

variable "dbuser" {
  type = string
}

variable "dbpass" {
  type = string
}
