output "policy_arns" {
  value       = { for k, v in aws_organizations_policy.scp : k => v.arn }
  description = "Map of policy ARNs."
}

output "policy_ids" {
  value       = { for k, v in aws_organizations_policy.scp : k => v.id }
  description = "Map of policy IDs."
}
