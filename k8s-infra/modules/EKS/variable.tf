variable "subnet_ids" {
    description = "Private subnet id's"
    type = list(string)
  
}


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
}

variable "cluster_version" {
    description = "EKS cluster version"
    type = string
  
}