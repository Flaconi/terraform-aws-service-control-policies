# Create an AWS Organization policy for each policy template
resource "aws_organizations_policy" "scp" {
  for_each = { for policy in var.policies : policy.name => policy }

  name        = each.key
  description = each.value.description
  content     = templatefile(lookup(each.value, "file"), {})
}

resource "aws_organizations_policy_attachment" "attach_scp" {
  for_each = {
    for policy in aws_organizations_policy.scp :
    policy.name => policy
  }
  policy_id = each.value.id
  target_id = flatten([for p in var.policies : p.target_ids if p.name == each.key])[0]
}
