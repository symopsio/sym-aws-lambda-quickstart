# Slack Channel to send integration or runtime errors to
error_channel = "#sym-errors"

flow_vars = {
  # Slack Channel where requests should go
  request_channel = "#sym-requests"

  # Optional safelist of users that can approve requests
  approvers = "foo@myco.com,bar@myco.com"
}

# Slack Workspace where Sym is installed
slack_workspace_id = "CHANGEME"

# Your org slug will be provided to you by your Sym onboarding team
sym_org_slug = "CHANGEME"

# Optionally add more tags to the AWS resources we create
tags = {
  "vendor" = "symops.com"
}
