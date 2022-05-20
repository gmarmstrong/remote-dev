#!/usr/bin/env python3

import os
import shutil
import subprocess
from argparse import ArgumentParser, Namespace


# TODO Use config file/argument/envvars
INSTANCE_ZONE = 'us-east1-b'
INSTANCE_NAME = 'remote-dev'
PROJECT_ID = 'gmarmstrong'
TERRAFORM_VERSION = '1.1.9'  # refer to https://www.terraform.io/downloads
TERRAFORM_VERSION_SHA256SUM = '9d2d8a89f5cc8bc1c06cb6f34ce76ec4b99184b07eb776f8b39183b513d7798a'
# NOTE: must match sha256sum of CONTENTS of
# https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
# (of the Terraform binary itself, not of the archive)


def gcloud_setup():
    subprocess.run(['gcloud', 'config', 'set', 'project', PROJECT_ID])
    subprocess.run(['./set_acls.sh', PROJECT_ID])


def cloud_build_setup():
    subprocess.run(['git', 'submodule', 'update', '--init'])
    subprocess.run(['gcloud', 'builds', 'submit', 'cloud-builders-community/packer'])  # TODO portable path
    subprocess.run(['gcloud', 'builds', 'submit', 'cloud-builders-community/terraform',  # TODO portable path
                    f'--substitutions=_TERRAFORM_VERSION={TERRAFORM_VERSION},'
                    f'_TERRAFORM_VERSION_SHA256SUM={TERRAFORM_VERSION_SHA256SUM}'])


def build_packer():
    subprocess.run(['gcloud', 'builds', 'submit', 'packer'])


def build_terraform_states():
    subprocess.run(['gcloud', 'builds', 'submit', 'terraform/states'])  # TODO portable path


def build_terraform():
    subprocess.run(['gcloud', 'builds', 'submit', 'terraform'])


def create():
    gcloud_setup()
    build_packer()
    build_terraform_states()
    build_terraform()


def destroy():
    subprocess.run(['gcloud', 'builds', 'submit', 'terraform', '--config=terraform/cloudbuild-destroy.yaml'])
    subprocess.run(['gcloud', 'builds', 'submit', 'terraform/states',
                    '--config=terraform/states/cloudbuild-destroy.yaml'])  # TODO portable path
    subprocess.run(['gsutil', '-m', 'rm', '-r', 'gs://${PROJECT_ID}_logs'])
    subprocess.run(['gsutil', '-m', 'rm', '-r', 'gs://${PROJECT_ID}_tf-state'])


def vscode_ssh_prepare():
    # establish first ssh connection, write keys to ~/.google_compute_known_hosts
    subprocess.run(['gcloud', 'compute', 'ssh', INSTANCE_NAME, f'--zone={INSTANCE_ZONE}',
                    '--tunnel-through-iap', '--command=exit'])
    # print the equivalent native ssh command
    subprocess.run(['gcloud', 'compute', 'ssh', INSTANCE_NAME, f'--zone={INSTANCE_ZONE}',
                    '--tunnel-through-iap', '--dry-run'])
    print('See https://medium.com/@albert.brand/f9fb54676153')


def depend_upon(commands: list[str]):
    for command in commands:
        if not shutil.which(command):
            raise OSError


def version():
    # reads ./VERSION file
    with open(os.path.join('VERSION')) as version_file:  # TODO better path
        return version_file.read().strip()


def setup_parsers():
    # top-level command
    parser_top = ArgumentParser()
    parser_top.add_argument('--version', action='version', version=version())

    # subparsers
    subparsers = parser_top.add_subparsers(title='subcommands')

    # sub-command: calculate
    subcommand_create = subparsers.add_parser('create')
    subcommand_create.set_defaults(func=create)

    # sub-command: verify
    subcommand_destroy = subparsers.add_parser('destroy')
    subcommand_destroy.set_defaults(func=destroy)

    args: Namespace = parser_top.parse_args()
    if any(vars(args).values()):
        args.func(args)


if __name__ == '__main__':
    depend_upon(['gcloud', 'git'])
    setup_parsers()
