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


#######################################
# Config
#######################################


function apt_install() {
  sudo apt-get install --no-install-recommends -y "$@"
}


function uv_init() {
  local python_version="${1}";
  uv init --python="${python_version}";
  [[ $? -ne 0 ]] && {
    mylogp "error" "Initializing uv with python version: ${python_version} failed!";
    return 1;
  }
}

function uv_venv_create() {
  local venv_path="${1}";
  uv venv "${venv_path}";
  [[ $? -ne 0 ]] && {
    mylogp "error" "Creating uv virtual environment in: ${venv_path} failed!";
    return 1;
  }
}

function install_packages_from_file() {
  local requirements_file="${1}";
  uv pip sync "${requirements_file}";
  [[ $? -ne 0 ]] && {
    mylogp "error" "Installing packages from requirements file: ${requirements_file} failed!";
    return 1;
  }
}

function save_current_packages_to_file() {
  local requirements_file="${1}";
  uv pip freeze > "${requirements_file}";
  [[ $? -ne 0 ]] && {
    mylogp "error" "Syncing installed packages to requirements file: ${requirements_file} failed!";
    return 1;
  }
}

function sync_uv_environment() {
  local pyproject_file="pyproject.toml";
  [[ -f "${pyproject_file}" ]] && {
    uv sync || {
      mylogp "error" "Syncing uv environment from ${pyproject_file} failed!";
      return 1;
    }
  }
}

# Usage: uv_add_packages [--frozen] [--dev] package1 package2 ...
function uv_add_packages() {
  local frozen_flag; local dev_flag;
  while [[ "$1" == --* ]]; do
    case "$1" in
      --frozen) frozen_flag="--frozen"; shift ;;
      --dev) dev_flag="--dev"; shift ;;
      *) break ;;
    esac
  done
  [[ -z "$@" ]] && {
    mylogp "error" "No packages specified to add to uv environment!";
    return 1;
  }
  [[ -n "${dev_flag}" ]] && {
    mylog "info" "Adding packages with dev flag: ${dev_flag}";
    [[ -n "${frozen_flag}" ]] && {
      mylog "info" "Adding packages with frozen flag: ${frozen_flag}";
      uv add "${dev_flag}" "$@" "${frozen_flag}" && return 0;
    } || {
      uv add "${dev_flag}" "$@" && return 0;
    }
  } || {
    [[ -n "${frozen_flag}" ]] && {
      mylog "info" "Adding packages with frozen flag: ${frozen_flag}";
      uv add "$@" "${frozen_flag}" && return 0;
    } || {
      uv add "$@" && return 0;
    }
  }
  [[ $? -ne 0 ]] && {
    mylogp "error" "Adding packages to uv environment failed!";
    return 1;
  }
}

function install_environment_activation_script() {
  local template_script_dir="scripts"; local activate_script=".activate"; local template_activate_script="_activate";
  [[ ! -f "${activate_script}" ]] && [[ -f "${template_script_dir}/${template_activate_script}" ]] && \
    cp -v "${template_script_dir}/${template_activate_script}" "${activate_script}";
  return 0;
}


function py_setup_upgrade() {
  local desired_python_version="${1}"; local venv_path="${2}";
  local python_version_file=".python-version"; local mise_config_file=".mise.toml";
  local pyproject_file="pyproject.toml"; local requirements_file="requirements.txt";
  local uv_lock_file="uv.lock";
  # [[ ! -f "${mise_config_file}" ]] && mise use "python@${desired_python_version}";
  [[ -f "${python_version_file}" ]] && {
    local current_python_version=$(cat "${python_version_file}");
    [[ "${current_python_version}" = "${desired_python_version}" ]] && {
      mylogp "info" "Python version ${desired_python_version} is already set in ${python_version_file}";
    } || {
      rm -f "${python_version_file}"; [[ -d "${venv_path}" ]] && rm -rf "${venv_path}";
      mylogp "info" "Updating python version from ${current_python_version} to ${desired_python_version}";
    }
  }
  [[ ! -f "${mise_config_file}" ]] && touch "${mise_config_file}";
  mise use "python@${desired_python_version}" || {
    mylogp "error" "Setting python version to ${desired_python_version} with mise failed!";
    return 1;
  }
  [[ ! -f "${pyproject_file}" ]] && {
    uv_init "${desired_python_version}" || {
      mylogp "error" "Initializing uv with python version: ${desired_python_version} failed!";
      return 1;
    }
    [[ ! -f "${python_version_file}" ]] && {
      echo "${desired_python_version}" > "${python_version_file}";
      mylogp "info" "Set python version to ${desired_python_version} in ${python_version_file}";
    }
  }
  [[ ! -d "${venv_path}" ]] && {
    uv_venv_create "${venv_path}" || {
      mylogp "error" "Creating uv virtual environment in: ${venv_path} failed.";
      return 1;
    }
  }
  install_environment_activation_script || {
    mylogp "error" "Failed to install environment activation script";
  }
  [[ -d "${venv_path}" ]] && {
    [[ -e "${venv_path}/bin/activate" ]] && source "${venv_path}/bin/activate" && \
      mylogp "info" "+ Python virtual environment activated";
    sync_uv_environment || {
      mylogp "error" "Syncing uv environment from ${pyproject_file} failed.";
    }
    [[ -f "${requirements_file}" ]] && {
      install_packages_from_file "${requirements_file}" || {
        mylogp "error" "Installing packages from requirements file: ${requirements_file} failed.";
        return 1;
      }
    }
    uv_add_packages --dev "pre-commit" basedpyright python-lsp-server python-lsp-jsonrpc tiktoken ruff black pynvim --frozen || {
      mylogp "error" "Failed to add essential development packages to uv environment.";
      return 1;
    }
  }
  return 0;
}



main() {
  local desired_python_version="${1:-3.13}"; local venv_path="${2:-.venv}";
  local nvim_config_dir="${HOME}/.config/nvim";
  # local current_dir=$(pwd -P); local venv_path="${current_dir}/.venv";

  # directory is used by pipenv
  mkdir -p "${HOME}/.local/share/virtualenvs";
  # directory is used by poetry, pre-commit directory for installing plugins
  mkdir -p "${HOME}/.cache/{pypoetry,pre-commit}";
  mylogp "info" "+ Created necessary global directories";
  py_setup_upgrade "${desired_python_version}" "${venv_path}" && {
    mylogp "info" "+ Python environment setup and upgrade completed successfully";
  } || {
    mylogp "error" "Python environment setup and upgrade failed!";
    return 1;
  }
  # [[ -d "${nvim_config_dir}" ]] && {
  #   mylogp "info" "+ Installing Neovim Python packages";
  #   uv pip install pynvim && {
  #     mylogp "info" "+ Neovim Python package installed successfully";
  #   } || {
  #     mylogp "error" "Installing Neovim Python package failed!";
  #   }
  # }


  return 0;
}

main $@

SCRIPT_NAME="${PREVIOUS_SCRIPT_NAME}"
exit 0


