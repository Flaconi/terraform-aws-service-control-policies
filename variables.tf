variable "policies" {
  description = "List of policies with their details"
  type = list(object({
    name        = string
    file        = string
    target_ids  = list(string)
    description = string
  }))
}
