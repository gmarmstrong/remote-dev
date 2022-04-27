#!/usr/bin/env bash

# Credit to https://github.com/terraform-linters/tflint/issues/527#issuecomment-613394582

set -eo pipefail

tflint --version

config_file="$(git rev-parse --show-toplevel)/.tflint.hcl"

echo "Scanning the modules"
readarray -t module_dirs < <(find . -name .terraform -prune , -type f -name '*.tf' -printf '%h\n' | sort | uniq)
for module_dir in "${module_dirs[@]}"; do
  echo
  echo "======================================================================"
  echo "Checking ${module_dir}"
  echo "======================================================================"
  echo
  (
    cd "${module_dir}"
    terraform init -backend=false
    profiles=()
    readarray -O ${#profiles[@]} -t profiles < <(find . -maxdepth 1 -type f -name 'terraform.tfvars.*' -printf '%f\n')
    readarray -O ${#profiles[@]} -t profiles < <(find . -maxdepth 1 -type f -name '*.tfvars' -printf '%f\n')
    if [[ ${#profiles[@]} -gt 0 ]]; then
      for profile in "${profiles[@]}"; do
        echo
        echo "Using variable values from: ${profile}"
        echo
        tflint --config="${config_file}" --var-file="${profile}"
      done
    else
      echo
      echo "Using default variable values"
      echo
      tflint --config="${config_file}"
    fi
  )
done