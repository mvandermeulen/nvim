#!/usr/bin/env zsh

PREVIOUS_SCRIPT_NAME="${SCRIPT_NAME:-zsh}"; export SCRIPT_NAME="${0:A:t}";
SCRIPT_DIRECTORY=${0:a:h}
OTHER_SCRIPT_DIRECTORY="$(dirname $0:A)"

#######################################
# Libraries
#######################################
[[ -f "${HOME}/.zshenv" ]] && source "${HOME}/.zshenv"
source "${SHARED_FUNCTIONS_PATH}/log.functions.sh" || {
  echo "Fatal error loading required log scripts!"; return 1;
}
source "${SHARED_FUNCTIONS_PATH}/util.functions.sh" || {
  mylogp "error" "Fatal error loading required utility scripts!"; return 1;
}


# If one command exits with an error, stop the script immediately.
# set -eo pipefail

# Print every line executed to the terminal.
# set -x

NOW=$(date +"%Y-%m-%d-%H-%M-%S")
LOG_DIR="${HOME}/.local/logs/goinstall"; mkdir -p "${LOG_DIR}";
FAIL_LOG_PREFIX="failed_installs_"; SUCCESS_LOG_PREFIX="succesful_installs_";
FAIL_LOG="${LOG_DIR}/${FAIL_LOG_PREFIX}${NOW}.log"; SUCCESS_LOG="${LOG_DIR}/${SUCCESS_LOG_PREFIX}${NOW}.log";
GO_BIN_DIR="${HOME}/go/bin"; mkdir -p "${GO_BIN_DIR}";
LOCAL_BIN_DIR="${HOME}/.local/bin"; mkdir -p "${LOCAL_BIN_DIR}";

GOLANG_STD_PACKAGES=("golang.org/x/tools/gopls@latest" \
  "github.com/google/gops@latest" \
  "github.com/google/go-licenses@latest" \
  "mvdan.cc/gofumpt@latest" \
  "golang.org/x/lint/golint@latest" \
  "github.com/hotei/deadcode@latest" \
  "github.com/go-critic/go-critic/cmd/gocritic@latest" \
  "github.com/go-delve/delve/cmd/dlv@latest" \
  "github.com/jstemmer/gotags@latest" \
  "github.com/tommy-muehle/go-mnd/v2/cmd/mnd@latest" \
  "github.com/securego/gosec/cmd/gosec@latest" \
  "github.com/yagipy/maintidx/cmd/maintidx@latest" \
  "golang.org/x/vuln/cmd/govulncheck@latest" \
  "golang.org/x/perf/cmd/benchstat@latest")

# golang staticcheck
GOLANG_STATIC_PKGS=("honnef.co/go/tools/cmd/staticcheck@latest" \
  "honnef.co/go/tools/cmd/keyify@latest" \
  "honnef.co/go/tools/cmd/structlayout-pretty@latest" \
  "honnef.co/go/tools/cmd/structlayout-optimize@latest" \
  "honnef.co/go/tools/cmd/keyify@latest" \
  "honnef.co/go/tools/cmd/structlayout@latest")

# more tools
# go install go.uber.org/mock/mockgen@latest
MORE_GOLANG_TOOLS=("github.com/golang/mock@latest" \
  "github.com/fatih/gomodifytags@latest" \
  "github.com/dotzero/git-profile@latest" \
  "gotest.tools/gotestsum@latest" \
  "github.com/maaslalani/slides@latest" \
  "github.com/go-swagger/go-swagger/cmd/swagger@latest" \
  "github.com/blmayer/awslambdarpc@latest" \
  "github.com/xxxserxxx/gotop/v4/cmd/gotop@latest" \
  "github.com/jesseduffield/lazydocker@latest" \
  "github.com/golangci/golangci-lint/cmd/golangci-lint@v1.54.2")
# Install fixed version of linter !!

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

function golang_install() {
  go install "${1}"
  if [[ $? -ne 0 ]]; then
    echo "Failed to install package: ${1}"
    echo "${1}" >> "${FAIL_LOG}";
    return 1
  else
    echo "${1}" >> "${SUCCESS_LOG}";
    return 0
  fi
}


for pkg in $GOLANG_STD_PACKAGES; do
  if check_past_installs_log "${pkg}"; then
    echo "Package ${pkg} has already been installed, skipping."
    continue
  fi
  if ! golang_install "${pkg}"; then
    echo "Failed to install package ${pkg}"
  fi
done

for pkg in $GOLANG_STATIC_PKGS; do
  if check_past_installs_log "${pkg}"; then
    echo "Package ${pkg} has already been installed, skipping."
    continue
  fi
  if ! golang_install "${pkg}"; then
    echo "Failed to install package ${pkg}"
  fi
done

for pkg in $MORE_GOLANG_TOOLS; do
  if check_past_installs_log "${pkg}"; then
    echo "Package ${pkg} has already been installed, skipping."
    continue
  fi
  if ! golang_install "${pkg}"; then
    echo "Failed to install package ${pkg}"
  fi
done

JQ_LSP_BINARY="$HOME/.local/bin/jq-lsp";
JQ_LSP_SRC="github.com/wader/jq-lsp@master";
if [[ ! -e "$JQ_LSP_BINARY" ]]; then
  echo "+ jq-lsp binary not found at $JQ_LSP_BINARY"
  if golang_install "${JQ_LSP_SRC}"; then
    echo "+ jq-lsp binary installed successfully"
    ln -s "$(go env GOPATH)/bin/jq-lsp" "${JQ_LSP_BINARY}"
  else
    echo "+ Failed to install jq-lsp binary"
  fi
else
  echo "+ jq-lsp binary found in $JQ_LSP_BINARY"
fi

SQLS_SERVER_NAME="sqls"; SQLS_SERVER_BINARY="${LOCAL_BIN_DIR}/${SQLS_SERVER_NAME}";
SQLS_SERVER_SRC="github.com/sqls-server/${SQLS_SERVER_NAME}@latest";
if [[ ! -e "$SQLS_SERVER_BINARY" ]]; then
  echo "+ sqls binary not found at $SQLS_SERVER_BINARY"
  if golang_install "${SQLS_SERVER_SRC}"; then
    echo "+ sqls binary installed successfully"
    if [[ -e "$(go env GOPATH)/bin/${SQLS_SERVER_NAME}" ]]; then
      echo "+ Creating symlink for sqls binary in ${LOCAL_BIN_DIR}"
      ln -s "$(go env GOPATH)/bin/${SQLS_SERVER_NAME}" "${SQLS_SERVER_BINARY}"
    fi
  else
    echo "+ Failed to install sqls binary"
  fi
else
  echo "+ sqls binary found at ${SQLS_SERVER_BINARY}"
fi


