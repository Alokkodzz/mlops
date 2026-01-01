variable "node_groups" {
  description = "EKS node group configuration"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
  }))
  default = {
    general = {
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      scaling_config = {
        desired_size = 1
        max_size     = 1
        min_size     = 1
      }
    }
  }
}

variable "cluster_version" {
    description = "EKS cluster version"
    type = string
    default = "1.34"
  
}