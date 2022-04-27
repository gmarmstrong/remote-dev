# Remote Development _(remote-dev)_

[![Lint Checks](https://github.com/gmarmstrong/remote-dev/actions/workflows/tflint.yml/badge.svg)](https://github.com/gmarmstrong/remote-dev/actions/workflows/tflint.yml) [![Security Checks](https://github.com/gmarmstrong/remote-dev/actions/workflows/tfsec.yml/badge.svg)](https://github.com/gmarmstrong/remote-dev/actions/workflows/tfsec.yml)

Automatically provisions an ephemeral development server on Google Cloud Platform. An immutable machine image is built with [Packer](https://packer.io/) and deployed on a [Compute Engine](https://cloud.google.com/compute) instance with [Terraform](https://www.terraform.io/), all via [Cloud Build](https://cloud.google.com/cloud-build).

## Usage

### :white_check_mark: Prerequisites

#### :lock: Generate your SSH key pair

If you don't have an SSH key pair already, generate one (preferably with a high-entropy passphrase):

```bash
ssh-keygen -o -a 100 -t ed25519 -C remote-dev
```

#### :gear: Customize the configuration files:

  - `PROJECT_ID` in `run.sh`
  - `terraform/env/prod/terraform.tfvars`
  - `packer/config.auto.pkvars.hcl`

### :rocket: Deploy the server

In the `remote-dev` repository, run

```bash
./run.sh create
```

Then to authenticate and log in, run

```bash
# replace us-east1-b, alice@remote-dev, and project-name with your own values
gcloud compute ssh --zone "us-east1-b" "alice@remote-dev" --tunnel-through-iap --project "project-name"
gcloud-compute config-ssh
# Add "User=alice" to new entry in ~/.ssh/config if host/guest usernames don't match
```

### :collision: Destroy the server

In the `remote-dev` repository, run

```bash
./run.sh destroy
```

## :information_source: About

### :toolbox: Tools used

- [Google Cloud Build](https://cloud.google.com/build)
- [Packer](https://www.packer.io/)
- [Terraform](https://www.terraform.io/)

### 📃 License

This project (being derivative of [2n3g5c9/remote-dev](https://github.com/2n3g5c9/remote-dev)) is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
