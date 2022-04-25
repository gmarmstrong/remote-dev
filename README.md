# This is a fork of [2n3g5c9/remote-dev](https://github.com/2n3g5c9/remote-dev)

## ✅ Prerequisites

This repository helps automate the provisioning of an ephemeral development server on
[Google Cloud Platform](https://cloud.google.com/). An immutable image is built with [Packer](https://packer.io/) and
deployed on an `e2-medium` [Compute Engine](https://cloud.google.com/compute) instance (in `us-east1-b` to fall in the
free tier) with [Terraform](https://www.terraform.io/), all via [Cloud Build](https://cloud.google.com/cloud-build).
Keep in mind you'll be charged for the External IP address.

### Generate your SSH key pair

If you don't have an SSH key pair already, generate one (preferably with a high-entropy passphrase):

```bash
ssh-keygen -o -a 100 -t ed25519 -C remote-dev
```

### Configuration

+ In `remote-dev/terraform/env/prod/terraform.tfvars`, replace the SSH user/public key with your own values
+ Modify `remote-dev/packer/packer.json` as well
+ Modify the bootstrap/ directory to create your own environment

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

- [Google Cloud Build](https://cloud.google.com/cloud-build): A tool to "Continuously build, test, and deploy".
- [Packer](https://www.packer.io/): A tool to "Build Automated Machine Images".
- [Terraform](https://www.terraform.io/): A tool to "Write, Plan, and Create Infrastructure as Code".

## 📃 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
