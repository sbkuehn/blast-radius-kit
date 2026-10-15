# Blast Radius Kit

By Shannon Eldridge-Kuehn · Copyright (c) September 2026

Companion repo for the Cloudy Musings post **"Blast radius: fault domains, availability zones, and why your zone 1 isn't my zone 1."**

The post explains high availability as a ladder of blast radius: fault domains protect you from a rack, availability zones protect you from a building, and regions protect you from a geography. This repo gives you the hands-on side of that story. Read-only shell scripts let you explore your own subscriptions and accounts, and Terraform deploys each layer on Azure, AWS, and Google Cloud so you can see where your VMs actually land.

## What's inside

| Folder | Tool | What it covers | Layer |
| --- | --- | --- | --- |
| [`01-explore/`](01-explore/) | Shell | Fault domain counts, logical-to-physical zone mapping, VM size availability per zone, AWS AZ IDs, GCP zones | All |
| [`02-azure/availability-set/`](02-azure/availability-set/) | Terraform | Availability set with fault and update domains | Rack |
| [`02-azure/vmss-flex-zonal/`](02-azure/vmss-flex-zonal/) | Terraform | VMSS Flex spread across availability zones | Building |
| [`03-aws/placement-groups/`](03-aws/placement-groups/) | Terraform | Partition and spread placement groups, subnets pinned by AZ ID | Rack, building |
| [`04-gcp/spread-and-mig/`](04-gcp/spread-and-mig/) | Terraform | Spread placement policy plus a regional managed instance group | Rack, building |
| [`tests/`](tests/) | Shell | Convention checks, shellcheck, terraform fmt and validate | |

## Conventions

Everything in this repo is either a shell script you run to look around or a Terraform folder you deploy. Each one follows the same pattern, so once you've read one you know how to read the rest.

**Shell scripts** in `01-explore/` are all read-only and share the same shape: a header with a description, usage examples, required CLI, and a docs link; `set -euo pipefail`; a `-h` flag; a check that the right CLI is installed; and the region as the first argument. Names start with the cloud they target: `az-`, `aws-`, or `gcp-`.

**Terraform folders** each contain exactly five files: `versions.tf`, `variables.tf`, `main.tf`, `outputs.tf`, and `terraform.tfvars.example`. Variables follow the same order everywhere: the account (`subscription_id` or `project_id`, if the cloud needs one), then `region`, then `prefix`, then the folder's own settings, ending with `instance_size`. Every resource is tagged or labeled `project = blast-radius-kit` plus `layer = rack` or `building`, and every folder outputs `group_id`, `zones` (where it applies), and `check_placement`, a ready-to-run command that shows where your instances landed.

`tests/run-tests.sh` enforces both sets of rules, so a new script or folder that drifts from the pattern fails the test run.

## Start here: explore before you deploy

Everything in `01-explore/` is read-only, so it's safe to run against any subscription or account. These are the commands from the post's "Try it yourself" section, wrapped up with argument handling and comments.

```bash
# How many fault domains does my region offer? (some give 3, some only 2)
./01-explore/az-fault-domains.sh westus

# Is my "zone 1" the same building as yours? Compare two subscriptions.
./01-explore/az-zone-mapping.sh eastus2 <subscription-a> <subscription-b>

# Is this VM size offered in every zone, or restricted somewhere?
./01-explore/az-sku-zones.sh eastus2 Standard_D4s_v5

# AWS zone names next to their account-independent AZ IDs
./01-explore/aws-az-ids.sh us-east-1

# GCP zones in a region
./01-explore/gcp-zones.sh us-central1
```

You'll need the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli), [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), or [gcloud CLI](https://docs.cloud.google.com/sdk/docs/install) for whichever cloud you want to explore.

## Deploying with Terraform

> **Heads up:** the Terraform folders create real VMs that cost real money. They use small sizes by default, but tear them down when you're done.

Every folder works the same way:

```bash
cd 02-azure/availability-set   # or any other Terraform folder
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars

terraform init
terraform apply

# see where your instances landed
eval "$(terraform output -raw check_placement)"

terraform destroy
```

A few things worth knowing before you run them:

- **02-azure/availability-set:** `fault_domain_count` defaults to 2 because some regions only support 2. Bump it to 3 after checking your region with `az-fault-domains.sh`. The example tfvars file uses the post's "3 fault domains, 10 update domains" setup. Both counts are locked once the set exists, and variable validation stops you from asking for more than 3 fault domains or 20 update domains.
- **02-azure/vmss-flex-zonal:** the fault domain count is fixed at 1 because the zones do the spreading. Zone balancing is off so scale-out keeps working if one zone runs short on capacity.
- **03-aws/placement-groups:** subnets use `availability_zone_id` instead of `availability_zone`, so `use1-az1` means the same physical zone in every account. Partition count is capped at 7 per AZ, matching the AWS limit.
- **04-gcp/spread-and-mig:** placement policies work inside a single zone, so the spread instances all go into `spread_zone`. The regional managed instance group covers the building layer by spreading across `zones`.

## Running the tests

```bash
./tests/run-tests.sh
```

The harness checks every script against the conventions above and runs shellcheck on it, checks every Terraform folder's layout, and runs `terraform fmt -check` and `terraform validate` on each one. Missing tools show up as skipped rather than failed. Set `TF_BIN=tofu` to use OpenTofu, or `SKIP_VALIDATE=1` if you're offline and can't download providers.

## Further reading

- [What are availability zones?](https://learn.microsoft.com/azure/reliability/availability-zones-overview) (Microsoft Learn)
- [Availability sets overview](https://learn.microsoft.com/en-us/azure/virtual-machines/availability-set-overview) (Microsoft Learn)
- [Availability options for Azure VMs](https://learn.microsoft.com/en-us/azure/virtual-machines/availability) (Microsoft Learn)
- [Orchestration modes for scale sets](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-orchestration-modes) (Microsoft Learn)
- [Placement strategies for EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-strategies.html) (AWS)
- [AZ IDs](https://docs.aws.amazon.com/global-infrastructure/latest/regions/az-ids.html) (AWS)
- [Placement policies overview](https://docs.cloud.google.com/compute/docs/instances/placement-policies-overview) (Google Cloud)
- [Regional managed instance groups](https://docs.cloud.google.com/compute/docs/instance-groups/regional-migs) (Google Cloud)

## License

[MIT](LICENSE)
