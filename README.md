# remote-dev

Automatically provisions an ephemeral development server on Google Cloud Platform. An immutable machine image is built with [Packer](https://packer.io/) and deployed on a [Compute Engine](https://cloud.google.com/compute) instance with [Terraform](https://www.terraform.io/), all via [Cloud Build](https://cloud.google.com/cloud-build).

## ✅ Prerequisites

### 🔒 Generate your SSH key pair

If you don't have an SSH key pair already, generate one (preferably with a high-entropy passphrase):

```bash
ssh-keygen -o -a 100 -t ed25519 -C remote-dev
```

### ⚙ Customize the configuration files:
  - `PROJECT_ID` in `run.sh`
  - `terraform/env/prod/terraform.tfvars`
  - `packer/config.auto.pkvars.hcl`

## 🚀 Deploy the server

In the `remote-dev` repository, run

```bash
./run.sh create
```

## 🧨 Destroy the server

In the `remote-dev` repository, run

```bash
./run.sh destroy
```

## 🪄 Tools used

- [Google Cloud Build](https://cloud.google.com/build)
- [Packer](https://www.packer.io/)
- [Terraform](https://www.terraform.io/)

## 📃 License

This project (a fork of a fork of [2n3g5c9/remote-dev](https://github.com/2n3g5c9/remote-dev)) is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
