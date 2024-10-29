variable "policies" {
  description = "List of policy configurations"
  type = list(object({
    name        = string
    description = string
    statements  = string       # Path to the JSON file containing policy statements
    target_ids  = list(string) # List of target account IDs or OU IDs
  }))
}

variable "tags" {
  description = "Tags to apply to all resources created in this module"
  type        = map(string)
  default     = {}
}
