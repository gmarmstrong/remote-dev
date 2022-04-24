#!/usr/bin/env bash

set -eu

export DEBIAN_FRONTEND=noninteractive

#DELTA_VERSION="0.8.3"
#GO_VERSION="1.17"
#NODE_VERSION="16"
#NVIM_VERSION="0.5.0"

apt-sources() {
    echo " ==> Adds additional APT sources"
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
}

apt-upgrade() {
    echo " ==> Upgrading packages"
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get auto-remove -y
}

apt-installs() {
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections

    echo " ==> Installing base packages"
    sudo apt-get update
    sudo apt-get install -y \
        git \
        mosh \
        neovim \
        python3 \
        python3-pip \
        sshguard \
        tmux \
        universal-ctags \
        unzip \
        xdg-utils
    sudo apt-get auto-remove -y
}

additional-installs() {
    VIM_PLUG="${HOME}/.config/nvim/autoload/plug.vim"
    if [ ! -f "${VIM_PLUG}" ]; then
        echo " ==> Installing vim-plug"
        curl -fLo "${VIM_PLUG}" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

    TPM="${HOME}/.tmux/plugins/tpm"
    if [ ! -d "${TPM}" ]; then
        echo " ==> Installing tpm"
        git clone https://github.com/tmux-plugins/tpm "${TPM}"
    fi

    TFENV="${HOME}/.tfenv"
    if [ ! -d "${TFENV}" ]; then
        echo " ==> Installing tfenv"
        git clone https://github.com/tfutils/tfenv.git ~/.tfenv
    fi

    if [ ! -d "/etc/google-cloud-ops-agent" ]; then
        echo " ==> Installing Ops Agent"
        curl -fsSL https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh | sudo bash -s -- --also-install
    fi
}

#pip-installs() {
#    echo " ==> Installing Python modules"
#    pip install -U jedi-language-server pre-commit pynvim
#    pip install pre-commit
#}

#go-installs() {
#    GO_ARCHIVE="go${GO_VERSION}.linux-amd64.tar.gz"
#    GO_ROOT="/usr/local"
#    if [ ! -d "${GO_ROOT}/go" ]; then
#        echo " ==> Installing Go"
#        curl -fLo ${GO_ARCHIVE} \
#            https://dl.google.com/go/${GO_ARCHIVE}
#        sudo tar -C ${GO_ROOT} -xzf ${GO_ARCHIVE}
#        rm ${GO_ARCHIVE}
#    fi
#}

#js-installs() {
    #if [ ! -f "/usr/bin/node" ]; then
    #    echo " ==> Installing Node.js"
    #    curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo bash -
    #    sudo apt-get install -y nodejs
    #fi

    #if [ ! -f "/usr/bin/yarn" ]; then
    #    echo " ==> Installing yarn"
    #    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    #    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    #    sudo apt-get update && sudo apt-get install -y yarn && sudo apt-get auto-remove
    #fi

    #echo " ==> Installing global node modules"
    #yarn global add ansible-language-server bash-language-server dockerfile-language-server-nodejs graphql-language-service-cli @tailwindcss/language-server typescript typescript-language-server vim-language-server vscode-langservers-extracted yaml-language-server
#}

copy-dotfiles() {
    echo " ==> Copying dotfiles"

    #mkdir -p $HOME/.config/fish
    #cp config/fish/config.fish "${HOME}/.config/fish/config.fish"
    #cp config/fish/fish_plugins "${HOME}/.config/fish/fish_plugins"
    cp config/aliases/aliases "${HOME}/.aliases"

    cp config/tmux/tmux.conf "${HOME}/.tmux.conf"

    cp config/git/gitconfig "${HOME}/.gitconfig"

    mkdir -p "${HOME}/.config/nvim"
    cp -r config/nvim/* "${HOME}/.config/nvim/"
}

#change-shell() {
    #echo " ==> Changing the shell to Fish"
    #if [ -f "/usr/bin/fish" ]; then
    #    sudo chsh -s /usr/bin/fish "${USER}"
    #fi
#}

vim-plugins-installs() {
    LOCAL_BIN="${HOME}/.local/bin"
    if [ -f "${LOCAL_BIN}/nvim.appimage" ]; then
      echo " ==> Installing vim plugins"
      /usr/bin/fish -i -c "${LOCAL_BIN}/nvim.appimage --headless +PlugInstall +qall"
    fi
}

do-it() {
    # Add APT sources.
    apt-sources

    # Update package index and upgrade packages.
    apt-upgrade

    # APT installs.
    apt-installs

    # Additional installs.
    additional-installs

    # Python modules installs.
    #pip-installs

    # Golang installs.
    #go-installs

    # Javascript installs.
    #js-installs

    # Dotfiles.
    copy-dotfiles

    # Shell
    #change-shell

    # Vim plugins installs.
    vim-plugins-installs
}

do-it
