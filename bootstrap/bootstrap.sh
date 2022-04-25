#!/usr/bin/env bash

set -eu

export DEBIAN_FRONTEND=noninteractive

apt_sources() {
    echo " ==> Adds additional APT sources"
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
}

apt_upgrade() {
    echo " ==> Upgrading packages"
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get auto-remove -y
}

apt_installs() {
    echo " ==> Installing base packages"
    sudo apt-get update
    sudo apt-get install -y \
        git \
        mosh \
        neovim \
        python3 \
        python3-pip \
        universal-ctags \
        unzip \
        xdg-utils
    sudo apt-get auto-remove -y
}

additional_installs() {
    if [ ! -d "/etc/google-cloud-ops-agent" ]; then
        echo " ==> Installing Ops Agent"
        curl -fsSL https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh | sudo bash -s -- --also-install
    fi
}

copy_dotfiles() {
    echo " ==> Copying dotfiles"
    cp config/aliases/aliases "${HOME}/.aliases"
    cp config/git/gitconfig "${HOME}/.gitconfig"
    mkdir -p "${HOME}/.config/nvim"
    cp -r config/nvim/* "${HOME}/.config/nvim/"
}

vim_plugins_installs() {
    # Install vim-plug
    VIM_PLUG="${HOME}/.config/nvim/autoload/plug.vim"
    if [ ! -f "${VIM_PLUG}" ]; then
        echo " ==> Installing vim-plug"
        curl -fLo "${VIM_PLUG}" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    # Install vim plugins
    LOCAL_BIN="${HOME}/.local/bin"
    if [ -f "${LOCAL_BIN}/nvim.appimage" ]; then
      echo " ==> Installing vim plugins"
      "${LOCAL_BIN}/nvim.appimage --headless +PlugInstall +qall"
    fi
}

do_it() {
    apt_sources             # add apt repository sources
    apt_upgrade             # update apt package index and upgrade packages
    apt_installs            # install apt packages
    additional_installs     # miscellaneous installations
    copy_dotfiles           # copy dotfiles to their respective locations
    vim_plugins_installs    # install vim plugin manager and plugins
}

do_it
