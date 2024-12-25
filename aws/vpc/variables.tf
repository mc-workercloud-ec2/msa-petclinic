

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "environment" {
  description = "Runtime Environment such as default, develop, stage, production"
  type        = string

}