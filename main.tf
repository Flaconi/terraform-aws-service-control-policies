# Create an AWS Organization policy for each policy template
resource "aws_organizations_policy" "scp" {
  for_each = { for policy in var.policies : policy.name => policy }

  name        = each.key
  description = each.value.description
  content     = templatefile(lookup(each.value, "file"), {})
}

# Create a local variable to flatten policies with target IDs
locals {
  policy_attachments = [
    for policy in var.policies : [
      for target_id in policy.target_ids : {
        policy_name = policy.name
        target_id   = target_id
      }
    ]
  ]
}

# Flatten the local variable to a single list of attachments
locals {
  flattened_policy_attachments = flatten(local.policy_attachments)
}

# Attach SCP policies to multiple target accounts or OUs
resource "aws_organizations_policy_attachment" "attach_scp" {
  for_each = {
    for idx, attachment in local.flattened_policy_attachments :
    "${attachment.policy_name}-${attachment.target_id}" => attachment
  }

  policy_id = aws_organizations_policy.scp[each.value.policy_name].id
  target_id = each.value.target_id
}
