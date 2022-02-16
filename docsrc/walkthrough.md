ID: sym_lambda_quickstart
Summary: Sym helps engineering teams automate security workflows with a sophisticated access management platform.
Feedback Link: mailto:sales@symops.io
Analytics Account: UA-156651818-3

# Sym Lambda Quickstart Tutorial

## Welcome
Duration: 1:00

Sym helps engineering teams automate security workflows with a sophisticated access management platform that lets you bring audited & automatic just-in-time access to AWS resources, SQL databases, internal apps & dashboards, and a variety external SaaS products. Workflows are provisioned via infra-as-code, often right beside the definitions of the resources they protect, and are easily customizable with our Python SDK.

If you want to check out a demo, go [here](https://demo.symops.com/)!

### Workflow

Today I want to walk you through setting up a simple access control workflow using Slack, AWS Lambda and Sym. By the end of this tutorial, you'll have the ability to integrate any resource accessible from your AWS Lambdas with a fully-configurable request-and-approval flow, using a declaratively provisioned Slack bot.

The complete code for this tutorial can be found at [`@symopsio/sym-lambda-quickstart`](https://github.com/symopsio/sym-lambda-quickstart).

## What will it look like?
Duration: 1:00

Users will interact with this Sym `Flow` via Slack. Slack connects to the Sym platform, which executes a `Flow` that use the `Integrations` we are wiring together in this tutorial.

![End-User Workflow](img/SymEndUserWorkflow.jpg)

#### Making Requests

This is what a request will look like.

![Request Modal](img/RequestModal.png)

Sym will send a request for approval to the appropriate users or channel based on your [`impl.py`](https://github.com/symopsio/sym-lambda-quickstart/blob/main/modules/lambda-access-flow/impl.py).


![Approval Request](img/ApprovalRequest.png)

Finally, upon approval, Sym invokes your AWS Lambda function and updates Slack.

![Approved Access](img/ApprovedAccess.png)


## Environment Setup
Duration: 3:00

To complete this tutorial, you should [install Terraform](https://learn.hashicorp.com/terraform/getting-started/install), and make sure you have a working install of Python 3.

### What's Next

The [app environment](https://github.com/symopsio/sym-lambda-quickstart/tree/main/app) includes everything you need to get a Lambda workflow up and running. Just configure a few variables in [`terraform.tfvars`](https://github.com/symopsio/sym-lambda-quickstart/tree/main/app/terraform.tfvars) and you're on your way!

Here's all that you'll need to do:

- Set up the `symflow` CLI
- Install the Sym Slack app
- Configure your Slack channels
- Test your deploy flow
- Customize your Lambda implementation
- E2E test and more goodies!

## Set up the `symflow` CLI
Duration: 3:00

You'll need to work with the Sym team to get your organization set up with access to the Sym platform. Once you're onboarded, continue from here.

### Install the `symflow` CLI

The [`symflow`](https://docs.symops.com/docs/install-sym-flow-cli) CLI is what you use to interact with Sym's control plane.

```bash
$ brew install symopsio/tap/symflow
```

```
==> Tapping symopsio/tap
Cloning into '/opt/homebrew/Library/Taps/symopsio/homebrew-tap'...
remote: Enumerating objects: 1148, done.
remote: Counting objects: 100% (285/285), done.
remote: Compressing objects: 100% (222/222), done.
remote: Total 1148 (delta 134), reused 156 (delta 59), pack-reused 863
Receiving objects: 100% (1148/1148), 324.27 KiB | 6.36 MiB/s, done.
Resolving deltas: 100% (530/530), done.
Tapped 14 formulae (43 files, 582.7KB).
==> Downloading https://github.com/symopsio/sym-flow-cli-releases/releases/download/v1.3.7/sym-flow-cli-darwin-x64.tar.gz
######################################################################## 100.0%
==> Installing symflow from symopsio/tap
🍺  /opt/homebrew/Cellar/symflow/1.3.7: 10,351 files, 198MB, built in 33 second
```

### Login

We'll have to login before we can do anything else. Sym also supports SSO, if your organization has set it up.

```bash
$ symflow login
```

```
Sym Org: healthy-health
Username: yasyf@healthy-health.co
Password: ************
MFA Token: ******

Success! Welcome, Yasyf. 🤓
```

### Set your Org slug

You simply have to take the `slug` given to you by the Sym team, and set it in [`app/terraform.tfvars`](https://github.com/symopsio/sym-lambda-quickstart/tree/main/app/terraform.tfvars).

```hcl
# app/terraform.tfvars

sym_org_slug = "healthy-health"
```

## Install the Sym Slack app
Duration: 3:00

Now that you've got `symflow` installed, you need to install Sym's Slack app into your workspace.

### Grab your Workspace ID

The easiest place to find this is in the URL you see when you run Slack in your web browser. It will start with a `T`, and look something like `TABC123`.

This also goes in [`app/terraform.tfvars`](https://github.com/symopsio/sym-lambda-quickstart/tree/main/app/terraform.tfvars).

```hcl
# app/terraform.tfvars

slack_workspace_id = "TABC123"
```

### Provision your Slack app

`symflow` has a convenient way to provision an instance of Sym's Slack app. This command will generate an install link that you can either use directly, or forward on to your Workspace Administrator.

```bash
$ symflow services create --service-type slack --external-id T123ABC
```

```
Successfully set up service type slack with external ID TABC123!
Generated an installation link for the Sym Slack app:

https://static.symops.com/slack/install?token=xxx

Please send this URL to an administrator who has permission to install the app. Or, if that's you, we can open it now.

Would you like to open the Slack installation URL in a browser window? [Y/n]:
```

Once Slack is set up, try launching the Sym app with `/sym` in Slack.

You should see a welcome modal like this one, since we haven't set up a `Flow` yet:

![Slack Welcome Modal](img/SlackWelcome.png)



## Configure your Slack channels
Duration: 1:00

This `Flow` is set up to route access requests to the `#sym-requests` channel. You can change this channel in—wait for it—[`terraform.tfvars`](https://github.com/symopsio/sym-lambda-quickstart/tree/main/app/terraform.tfvars).

Sym will also send any errors that happen during a `Run` (due to external failures or config issues) to a configurable error channel. You'll never guess where you can configure this.

```hcl
# app/terraform.tfvars

flow_vars = {
  request_channel = "#sym-requests"
}
```

You can also change the channel that errors are routed to, which defaults to `#sym-errors`.


```hcl
# app/terraform.tfvars

error_channel = "#sym-errors"
```

## Test your deploy flow
Duration: 1:00

Now that Slack is set up, let's provision your Flow! We've packaged an example Lambda implementation in the [my-lambda](https://github.com/symopsio/sym-lambda-quickstart/tree/main/modules/my-lambda) module along with all your Sym configurations. This Lambda doesn't do anything interesting quite yet, but we can at least make sure all the pipes are connected.

```bash
$ export AWS_PROFILE=my-profile
$ cd app
$ terraform apply
```

```
...
Plan: 25 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

Apply complete! Resources: 25 added, 0 changed, 0 destroyed.
```

Positive
: By the way, if you plan to provision your flows from a CI pipeline, [we've got you covered](https://docs.symops.com/docs/using-bot-tokens).

### Try out a request!

You should be able to make a request now with `/sym req`. Once approved, the `my-lambda` example function should be invoked in your AWS account, and you'll see log output like:

```
START RequestId: dcb17aed-df38-4aba-b72f-4000fc63c871 Version: $LATEST
Got event:
sym_handler/handler.py:11 handle
log: SymLogEntry(
meta=LogEntryMeta(
schema_version=3,
),
run=LogEntryRun(
srn=SRN(org=my-org, model=run, slug=lambda_access, version=2.0.0, identifier=7cd568e8-d42a-4183-9007-d2b654dfce75),
parent=(
SRN(org=my-org, model=run, slug=flow_selection, version=1.0.0,
identifier=d394bcb6-3d98-4f32-a140-d79720faa81c)
),
flow=SRN(org=my-org, model=flow, slug=lambda_access, version=2.0.0),
),
event=LogEntryEvent(
srn=SRN(org=my-org, model=event, slug=approval, version=1.0.0),
type='approve',
template=SRN(org=my-org, model=template, slug=approval, version=1.0.0),
timestamp=datetime.datetime(2022, 2, 15, 14, 33, 8, 769366, tzinfo=datetime.timezone.utc),
),
...
```

## Customize your Lambda implementation
Duration: 3:00

Once you've got your Flow talking to the example AWS Lambda implementation, its time to customize the Lambda to do something interesting for your team. You can stick with the Lambda template we've provided in the [`my-lambda`]() module or replace this with a different Lambda function ARN. Just update your Sym Target to point to the updated ARN when you're done!

Sym invokes your Lambda function with a `SymLogEntry` payload. Read more about the properties of `SymLogEntry` in our [API docs](https://sym.stoplight.io/docs/sym-reporting), or head over to the [`lambda-templates`](https://github.com/symopsio/lambda-templates) repo to see example Lambdas in action.

## E2E test and more goodies!
Duration: 3:00

Now that you've configured your AWS Lambda implementation, its time to validate that your integration works end-to-end. Double check that your function is properly responding to escalation and de-escalation events and handling error cases!

### What's next?

Here are some next steps to consider:

* Set up [reporting](https://docs.symops.com/docs/reporting-overview). Ship audit data to a flexible group of `LogDestinations`.
* Update your `Flow` to require that users be members of a safelist to approve access.
  1. Configure `flow_vars.approvers` with the safelist of approvers in [`terraform.tfvars`](https://github.com/symopsio/sym-lambda-quickstart/tree/main/app/terraform.tfvars).
  2. Uncomment the `hook` annotation on the `on_approve` method in [`impl.py`](https://github.com/symopsio/sym-lambda-quickstart/tree/main/modules/lambda-access-flow/impl.py).
     This is just one example of what you can do with [hooks in the SDK!](https://docs.symops.com/docs/handlers)
* Manage [users](https://docs.symops.com/docs/manage-users). Sym handles the "happy path" where user emails match across systems automatically. You can use the `symflow` CLI to configure user mappings when required.
* Iterate on your `Flow` logic. Maybe change things to allow self-approval only for on-call users?
* Set up another access `Flow`!
