#!/usr/bin/zsh


# If one command exits with an error, stop the script immediately.
set -eo pipefail

# Print every line executed to the terminal.
set -x


apt-install() {
  sudo apt-get install --no-install-recommends -y "$@"
}

pip-install() {
  if [ "$UBUNTU_RELEASE" = "jammy"]; then
    pip install "$1"
  else
    pip install --break-system-packages "$1"
  fi
}

# directory is used by pipenv
mkdir -p $HOME/.local/share/virtualenvs

# directory is used by poetry
mkdir -p $HOME/.cache/pypoetry

# pre-commit directory for installing plugins
mkdir -p $HOME/.cache/pre-commit



# tldr for a short form man pages.
pip-install tldr

# Just gitgud
pip-install gitgud

pip-install mycli

pip-install pgcli

pip-install tomlkit

pip-install iredis

pip-install termcolor

pip-install libtmux

pip-install hiredis

pip-install "redis[hiredis]"

pip-install pre-commit

pip-install virtualenvwrapper

pip-install neovim-remote
