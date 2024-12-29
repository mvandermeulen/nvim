#!/opt/homebrew/bin/zsh


# If one command exits with an error, stop the script immediately.
# set -eo pipefail

# Print every line executed to the terminal.
# set -x


NOW=$(date +"%Y-%m-%d-%H-%M-%S")
LOG_DIR="${HOME}/.local/logs/npm"; mkdir -p "${LOG_DIR}";
FAIL_LOG_PREFIX="failed_installs_"; SUCCESS_LOG_PREFIX="succesful_installs_";
FAIL_LOG="${LOG_DIR}/${FAIL_LOG_PREFIX}${NOW}.log"; SUCCESS_LOG="${LOG_DIR}/${SUCCESS_LOG_PREFIX}${NOW}.log";

NODE_PACKAGES=("vscode-langservers-extracted" \
  "@ansible/ansible-language-server" \
  "@astrojs/language-server" \
  "bash-language-server" \
  "dockerfile-language-server-nodejs" \
  "@microsoft/compose-language-service" \
  "sql-language-server" \
  "svelte-language-server" \
  "tabby-agent" \
  "@vtsls/language-server" \
  "vls" \
  "@tailwindcss/language-server" \
  "yaml-language-server" \
  "typescript-language-server" \
  "diagnostic-languageserver" \
  "eslint_d" \
  "prettier" \
  "stylelint"  \
  "stylelint-config-standard" \
  "stylelint-config-recommended")

function check_past_installs_log() {
  local result=$(egrep -qc "^${1}$" "${LOG_DIR}/${SUCCESS_LOG_PREFIX}"*);
  if [[ $result -gt 0 ]]; then
    return 0
  else
    return 1
  fi
}

function apt-install() {
  sudo apt-get install --no-install-recommends -y "$@"
}

function npm_install() {
  npm install -g "${1}"
  if [[ $? -ne 0 ]]; then
    echo "Failed to install package: ${1}"
    echo "${1}" >> "${FAIL_LOG}";
    return 1
  else
    echo "${1}" >> "${SUCCESS_LOG}";
    return 0
  fi
}

for pkg in $NODE_PACKAGES; do
  if check_past_installs_log "${pkg}"; then
    echo "Package ${pkg} has already been installed, skipping."
    continue
  fi
  if ! npm_install "${pkg}"; then
    echo "---------------- ERROR ------------------"
    echo "Failed to install package ${pkg}"
  else
    echo "Successfully installed package ${pkg}"
  fi
done


exit 0

