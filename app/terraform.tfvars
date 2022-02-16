
# Slack Channel to send integration or runtime errors to
error_channel = "#sym-errors"

flow_vars = {
  request_channel = "#sym-requests" # Slack Channel where requests should go

  approvers = "foo@myco.com,bar@myco.com" # Optional safelist of users that can approve requests
}

slack_workspace_id = "CHANGEME" # Slack Workspace where Sym is installed

# Your org slug will be provided to you by your Sym onboarding team
sym_org_slug = "CHANGEME"

# Optionally add more tags to the AWS resources we create
tags = {
  "vendor" = "symops.com"
}
