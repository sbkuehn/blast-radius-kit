# Changelog

All notable changes to this repo are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the repo uses [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-10-13

### Added

- `01-explore/`: read-only shell scripts for Azure fault domain counts, logical-to-physical zone mapping, VM size zone availability, AWS AZ IDs, and GCP zones.
- `02-azure/availability-set/`: Terraform for an availability set with fault and update domains, with validation on both limits.
- `02-azure/vmss-flex-zonal/`: Terraform for VMSS Flex spread across availability zones.
- `03-aws/placement-groups/`: Terraform for partition and spread placement groups, with subnets pinned by AZ ID.
- `04-gcp/spread-and-mig/`: Terraform for a spread placement policy and a regional managed instance group.
- `tests/run-tests.sh`: convention checks for scripts and Terraform folders, shellcheck, terraform fmt and validate.
