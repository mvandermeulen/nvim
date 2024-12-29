#!/opt/homebrew/bin/zsh


# If one command exits with an error, stop the script immediately.
# set -eo pipefail

# Print every line executed to the terminal.
# set -x

NOW=$(date +"%Y-%m-%d-%H-%M-%S")
LOG_DIR="${HOME}/.local/logs/cargo"; mkdir -p "${LOG_DIR}";
FAIL_LOG_PREFIX="failed_installs_"; SUCCESS_LOG_PREFIX="succesful_installs_";
FAIL_LOG="${LOG_DIR}/${FAIL_LOG_PREFIX}${NOW}.log"; SUCCESS_LOG="${LOG_DIR}/${SUCCESS_LOG_PREFIX}${NOW}.log";

CARGO_PACKAGES=("htmx-lsp" "pylyzer")

function apt-install() {
  sudo apt-get install --no-install-recommends -y "$@"
}

function check_past_installs_log() {
  local result=$(egrep -qc "^${1}$" "${LOG_DIR}/${SUCCESS_LOG_PREFIX}"*);
  if [[ $result -gt 0 ]]; then
    return 0
  else
    return 1
  fi
}

function cargo_install() {
  if [[ $# -gt 1 ]]; then
    if [[ "$2" == "locked" ]]; then
      cargo install --locked "${1}"
    else
      cargo install "${1}"
    fi
  else
    cargo install --locked "${1}"
  fi
  if [[ $? -ne 0 ]]; then
    echo "Failed to install package: ${1}"
    echo "${1}" >> "${FAIL_LOG}";
    return 1
  else
    echo "${1}" >> "${SUCCESS_LOG}";
    return 0
  fi
}

echo "+ Updating Rust toolchain"
rustup update stable

for pkg in $CARGO_PACKAGES; do
  if check_past_installs_log "${pkg}"; then
    echo "Package ${pkg} has already been installed, skipping."
    continue
  fi
  if ! cargo_install "${pkg}" "locked"; then
    echo "Failed to install locked package ${pkg}, trying without lock."
    if cargo_install "${pkg}"; then
      echo "Successfully installed package ${pkg}"
    else
      echo "---------------- ERROR ------------------"
      echo "Failed to install package ${pkg}"
    fi
  fi
done


exit 0


