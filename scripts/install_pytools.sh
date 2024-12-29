#!/opt/homebrew/bin/zsh


# If one command exits with an error, stop the script immediately.
# set -eo pipefail

# Print every line executed to the terminal.
# set -x


apt-install() {
  sudo apt-get install --no-install-recommends -y "$@"
}

pip_install() {
  if [[ "${UBUNTU_RELEASE}" = "jammy" ]]; then
    pip install -r "$1"
  else
    pip install -r "$1"
    # pip install --break-system-packages -r "$1"
  fi
}

# directory is used by pipenv
mkdir -p $HOME/.local/share/virtualenvs

# directory is used by poetry
mkdir -p $HOME/.cache/pypoetry

# pre-commit directory for installing plugins
mkdir -p $HOME/.cache/pre-commit

CURRENT_DIR=$(pwd); VENV_PATH="${CURRENT_DIR}/.venv"
if [[ ! -d "${VENV_PATH}" ]]; then
  echo "+ Could not find virtual environment in: ${CURRENT_DIR}"
  cd "${CURRENT_DIR}" && python3.12 -m venv .venv
fi

if [[ -d "${VENV_PATH}" ]]; then
  source "${VENV_PATH}/bin/activate"
  echo "+ Python virtual environment activated"
fi


pip_install requirements.txt


curl -LsSf https://astral.sh/ruff/install.sh | sh
