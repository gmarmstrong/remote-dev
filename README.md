# Remote Development _(remote-dev)_

[![GitHub](https://img.shields.io/github/license/gmarmstrong/remote-dev)](https://github.com/gmarmstrong/remote-dev/blob/main/LICENSE) [![Packer](https://github.com/gmarmstrong/remote-dev/actions/workflows/packer.yml/badge.svg)](https://github.com/gmarmstrong/remote-dev/actions/workflows/packer.yml) [![Lint Checks](https://github.com/gmarmstrong/remote-dev/actions/workflows/tflint.yml/badge.svg)](https://github.com/gmarmstrong/remote-dev/actions/workflows/tflint.yml)

Automatically provisions an ephemeral development server on Google Cloud
Platform. An immutable machine image is built with [Packer](https://packer.io/)
and deployed on a [Compute Engine](https://cloud.google.com/compute) instance
with [Terraform](https://www.terraform.io/), all via [Cloud
Build](https://cloud.google.com/cloud-build).

## Disclaimers

- Cloud computing costs money. One aim of this project is to
keep costs low by streamlining the create/destroy process, but be aware
that this code will provision resources that will incur charges to your
billing account. Please [read the license (MIT)](LICENSE) before
proceeding, with emphasis on
`"[...] IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, [...]`

- Additionally, this project is still in early development and **is not production-ready.** Security scans by
Snyk detect (as of
[commit `459f170`](https://github.com/gmarmstrong/remote-dev/tree/459f17028747ebd3f8778dd2f5296e3f5cd000dd)),
**7 "low severity misconfigurations"** in the Terraform design including, possibly non-exhaustively, the following:

  > - SNYK-CC-TF-185: "Google storage bucket does not use customer-managed keys to encrypt data
  > - SNYK-CC-GCP-271: "Object versioning is not enabled"
  > - SNYK-CC-GCP-274: "Logging is not enabled on storage bucket"
  > - SNYK-CC-GCP-461: "Delete protection is disabled"
  > - SNYK-CC-TF-91: "GCP Compute Firewall allows open egress"
  > - SNYK-CC-TF-184: "Customer supplied encryption keys are not used to encrypt VM compute instance"

## Usage

### :white_check_mark: Prerequisites

#### :lock: Generate your SSH key pair

If you don't have an SSH key pair already, generate one (preferably with a
high-entropy passphrase):

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

### Logging in

Before logging in for the first time, you'll need to go to
<https://console.cloud.google.com/security/iap> and make sure that IAP is
working properly. Specifically, you'll need a [firewall
rule](https://console.cloud.google.com/networking/firewalls) allowing
TCP-protocol ingress to the `remote-dev` target from IPv4 source range
35.235.240.0/20. To do so programmatically,
[see here](https://cloud.google.com/vpc/docs/using-firewalls#gcloud).

Then to authenticate and log in, run

```bash
# replace us-east1-b, alice@remote-dev, and project-name with your own values
gcloud compute ssh --zone "us-east1-b" "alice@remote-dev" --tunnel-through-iap --project "project-name"
```

In addition to accessing the new machine this way, you can also use
[Cloud Code extensions](https://cloud.google.com/code/docs) to use your
instance as a backend for IntelliJ and VS Code. For example, after installing
[the Cloud Code extension for VS Code](https://marketplace.visualstudio.com/items?itemName=GoogleCloudTools.cloudcode),
open the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd>)
and select `Cloud Code: Open in Cloud Shell...`, then select "Home" and your project
ID, and proceed iff the server's fingerprint is correct. From there, `./run.sh create`
(if you hadn't already) and then SSH into your machine.

### :collision: Destroy the server

**Caution:** the keyword here was _ephemeral_: this action will delete the whole
environment and all the data inside it. Push your changes to whatever you
were working on before destroying your system.

In the `remote-dev` repository, run

```bash
./run.sh destroy
```

## :information_source: About

### :toolbox: Tools used

- [Google Cloud Build](https://cloud.google.com/build)
- [Packer](https://www.packer.io/)
- [Terraform](https://www.terraform.io/)

### :page_with_curl: License

This project (being derivative of
[2n3g5c9/remote-dev](https://github.com/2n3g5c9/remote-dev)) is licensed under
the MIT License. See the [LICENSE](LICENSE) file for details.
