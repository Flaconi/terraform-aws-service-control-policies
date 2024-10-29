# Loop over each policy to create policy documents dynamically
data "aws_iam_policy_document" "scp_policies" {
  for_each = { for p in var.policies : p.name => p }

  dynamic "statement" {
    for_each = jsondecode(file(each.value.statements))
    content {
      sid       = lookup(statement.value, "Sid", null)
      effect    = lookup(statement.value, "Effect", "Deny")
      actions   = statement.value.Action
      resources = [lookup(statement.value, "Resource", "*")]

      dynamic "condition" {
        for_each = lookup(statement.value, "Condition", {})
        content {
          test     = condition.key
          variable = condition.value[0]
          values   = condition.value[1]
        }
      }
    }
  }
}

# Create policies with tags
resource "aws_organizations_policy" "scp" {
  for_each    = data.aws_iam_policy_document.scp_policies
  name        = each.value.name
  description = each.value.description
  content     = each.value.json
  tags        = var.tags
}

# Attach policies to targets with tags
resource "aws_organizations_policy_attachment" "attach_scp" {
  for_each  = { for p in var.policies : p.name => p }
  count     = length(each.value.target_ids)
  policy_id = aws_organizations_policy.scp[each.key].id
  target_id = each.value.target_ids[count.index]
}