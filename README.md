# remote-dev

## ✅ Prerequisites

This repository helps automate the provisioning of an ephemeral development server on
[Google Cloud Platform](https://cloud.google.com/). An immutable image is built with [Packer](https://packer.io/) and
deployed on an `e2-medium` [Compute Engine](https://cloud.google.com/compute) instance (in `us-east1-b` to fall in the
free tier) with [Terraform](https://www.terraform.io/), all via [Cloud Build](https://cloud.google.com/cloud-build).

### �� Generate your SSH key pair

If you don't have an SSH key pair already, generate one (preferably with a high-entropy passphrase):

```bash
ssh-keygen -o -a 100 -t ed25519 -C remote-dev
```

### ⚙ Configuration

+ You must modify the following files:
  - `PROJECT_ID` in `run.sh`
  - `terraform/env/prod/terraform.tfvars`
  - `packer/config.auto.pkvars.hcl`

## 🚀 How to deploy the server

In the `remote-dev` repository, run

```bash
./run.sh create
```

## 🧨 How to destroy the server

In the `remote-dev` repository, run

```bash
./run.sh destroy
```

## 🪄 Tech/frameworks used

- [Google Cloud Build](https://cloud.google.com/build)
- [Packer](https://www.packer.io/)
- [Terraform](https://www.terraform.io/)

## 📃 License

This project is licensed under the MIT License—see the [LICENSE](LICENSE) file for details. This repository is a fork of [2n3g5c9/remote-dev](https://github.com/2n3g5c9/remote-dev).