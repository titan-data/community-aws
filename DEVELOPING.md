# Project Development

For general information about contributing changes, see the
[Contributor Guidelines](https://github.com/titan-data/.github/blob/master/CONTRIBUTING.md).

For maintainers, the console for the AWS community account can be accessed
[here](https://029949851298.signin.aws.amazon.com/console).

## How it Works

All infrastructure is managed through Terraform. There are two workspaces:
`bootstrap` and `community`. The bootstrap links in only the configuration
required to set up shared terraform state, such that you can avoid the
chicken-and-egg problem and deploy those resources using local state.

The main infrastructure is found in the `community` directory, and is deployed
once the shared terraform state is available. When resources are dedicated to
a particular titan repository, such as S3 buckets or IAM profiles, then there
should be a `[respository].tf` file to manage the required resources. Additional
global resources can be placed in any appropriately named file.

This automation runs with admin privileges in the AWS community account,
leveraging Travis configuration variables to propagate secrets into the CI/CD
automation pipeline. All other AWS automation should use reduced privilege IAM
users and roles configured by this master automation.

## Building

If this is the first time building, you will need to run `terraform init` within
the `community` directory. Then you can run `terraform plan` within the
`community` directory. Because cloud resources often share a global namespace
(including things like S3 and DNS that have a global namespace across accounts),
the project is configured with a global variable, `project`, that is to name all
resources (including DNS names). It defaults to `titan-data`, but can be
overridden with `.tfvars` or `TF_VAR_` environment variables.

If you have access to a suitable AWS environment, you can run `terraform apply`
without conflicting with production resources. You will have to first run
`terraform apply` within the `bootstrap` directory to create the shared buckets
required to store terraform state.

## Testing

Run `terraform plan` and review . If you have access to an AWS environment, then you can
run `terraform apply` with a different `project` variable to test standing
up a complete alternate set of resources.

## Releasing

All releases are automatically applied when pushed to the master branch.
