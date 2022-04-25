# Build block docs: https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.googlecompute.ubuntu"]
  provisioner "shell" {
    environment_vars = [
      "SSH_USERNAME=${var.ssh_username}"
    ]
    inline = [
      "git clone ${var.base_repo} ${var.base_dir}",
      "cd ${var.base_dir}",
      "git submodule add -b ${var.dotfiles_branch} ${var.dotfiles_repo} ${var.dotfiles_dir}",
      "git submodule update --init",
      "(cd ${var.dotfiles_dir}; ./${var.dotfiles_script})"
    ]
  }
}
