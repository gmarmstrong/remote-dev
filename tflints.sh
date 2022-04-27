#!/usr/bin/env bash

# Credit to https://github.com/terraform-linters/tflint/issues/527#issuecomment-613394582

set -eo pipefail

terraform --version
tflint --version

cd terraform

# check for global tflint config
config_file="${PWD}/.tflint.hcl"
if [[ -f "$config_file" ]]; then
  config_arg="--config=$config_file"
fi

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
    tflint --init
    profiles=()
    readarray -O ${#profiles[@]} -t profiles < <(find . -maxdepth 1 -type f -name 'terraform.tfvars.*' -printf '%f\n')
    readarray -O ${#profiles[@]} -t profiles < <(find . -maxdepth 1 -type f -name '*.tfvars' -printf '%f\n')
    if [[ ${#profiles[@]} -gt 0 ]]; then
      for profile in "${profiles[@]}"; do
        tflint --init
        # profiles are .tfvars files, configs are .tflint.hcl files
        if [[ -f ".tflint.hcl" ]]; then
          if [[ config_arg != "" ]]; then
            echo "Warning: found both global and local tflint configs. Using the local one."
          fi
          config_arg="--config=.tflint.hcl"
        fi
        tflint --var-file="$profile" $config_arg # intentionally omitting quotes around $config_arg
      done
    else
    tflint $config_arg # intentionally omitting quotes around $config_arg

    fi
  )
done