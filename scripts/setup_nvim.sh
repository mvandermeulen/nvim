#!/usr/bin/zsh


echo "+ Starting neovim configuration setup."

export NEOVIM_CONFIG_DIR="$HOME/.config/nvim";


if [[ -d "${NEOVIM_CONFIG_DIR}" ]]; then
    TODAYS_DATE=$(date +"%Y%m%d"); NEOVIM_CONFIG_BACKUP_DIR="${NEOVIM_CONFIG_DIR}_${TODAYS_DATE}";
    mv -v "${NEOVIM_CONFIG_DIR}" "${NEOVIM_CONFIG_BACKUP_DIR}"
    if [[ -d "${NEOVIM_CONFIG_BACKUP_DIR}" ]]; then
      echo "+ Moved existing Neovim configuration to ${NEOVIM_CONFIG_BACKUP_DIR}"
    else
      echo "+ Failed to move existing Neovim configuration. Exiting."
      exit 1
    fi
fi

LOCAL_CONFIG_PATH="$HOME/dots/nvim"; LOCAL_CONFIG_INIT_FILE="${LOCAL_CONFIG_PATH}/init.lua"; LOCAL_CONFIG_LUA_PATH="${LOCAL_CONFIG_PATH}/lua"

if [[ ! -d "${LOCAL_CONFIG_PATH}" || ! -f "${LOCAL_CONFIG_INIT_FILE}" ]]; then
  CURRENT_DIR="$(pwd)"
  if [[ -d "${CURRENT_DIR}/nvim" && -d "${CURRENT_DIR}/nvim/lua" && -f "${CURRENT_DIR}/nvim/init.lua" ]]; then
    LOCAL_CONFIG_PATH="${CURRENT_DIR}/nvim"
  elif [[ -d "${CURRENT_DIR}/lua" && -f "${CURRENT_DIR}/init.lua" ]]; then
    LOCAL_CONFIG_PATH="${CURRENT_DIR}"
  else
    echo "+ Error could not find local neovim config"
    exit 1
  fi
fi

LOCAL_CONFIG_INIT_FILE="${LOCAL_CONFIG_PATH}/init.lua"; LOCAL_CONFIG_LUA_PATH="${LOCAL_CONFIG_PATH}/lua"

echo "+ Using config found at: ${LOCAL_CONFIG_PATH}"

ln -s "${LOCAL_CONFIG_PATH}" "${NEOVIM_CONFIG_DIR}"

echo "+ Completed linking configuration. Now running neovim."

function check_command_exists() {
    command -v "$1" >/dev/null 2>&1
}


if ! check_command_exists nvim; then
    echo "+ Neovim is not installed. Please install Neovim and re-run this script."
    exit 1
fi

function get_nvim_version() {
    nvim --version | head -n 1 | awk '{print $2}'
}

NVIM_VERSION=$(get_nvim_version)
REQUIRED_VERSION="0.7.0"


function backup_nvim_data() {
  local backups_dst_dir="${HOME}/.local/backup/nvim";
  local nvim_data_dir="${HOME}/.local/state/nvim"
  [[ $# -eq 1  && -n "${1}" ]] && backups_dst_dir="${1}";
  [[ ! -d "${backups_dst_dir}" ]] && mkdir -p "${backups_dst_dir}" && \
    echo "+ Created backups destination directory: ${backups_dst_dir}";
  if [[ -d "${nvim_data_dir}" ]]; then
    local backup_dir="nvim_data_backup_$(date +%Y%m%d_%H%M%S)"
    mv -v "${nvim_data_dir}" "${backups_dst_dir}/${backup_dir}" && {
      echo "+ Backed up existing Neovim data directory to: ${backup_dir}"
    }
  fi
}


function relocate_nvim_config() {
  local backups_dst_dir="${HOME}/.local/backup/nvim";
  local nvim_config_dir="${HOME}/.config/nvim";
  [[ $# -eq 1  && -n "${1}" ]] && backups_dst_dir="${1}";
  [[ ! -d "${backups_dst_dir}" ]] && mkdir -p "${backups_dst_dir}" && \
    echo "+ Created backups destination directory: ${backups_dst_dir}";
  if [[ -d "${nvim_config_dir}" ]]; then
    local backup_dir="nvim_config_backup_$(date +%Y%m%d_%H%M%S)";
    mv -v "${nvim_config_dir}" "${backups_dst_dir}/${backup_dir}" && {
      echo "+ Backed up existing Neovim config directory to: ${backup_dir}"
    }
  fi
}


function create_local_directories() {
  local HOME_LOCAL_DIRS=("bin" "docs" "include" "lib" "log" "man" "pipx" "share" "src" "state" "tmp" "share/marks/config" "share/nvim" "state/nvim");
  for item in ${HOME_LOCAL_DIRS[@]}; do
    LOCAL_DIR_FP="${HOME}/.local/${item}"
    [[ -L "${LOCAL_DIR_FP}" ]] && echo "Path ${LOCAL_DIR_FP} exists as symlink" && continue
    [[ ! -d "${LOCAL_DIR_FP}" ]] && {
      echo "+ Creating directory: ${LOCAL_DIR_FP}";
      mkdir -pv "${LOCAL_DIR_FP}";
    }
  done
}




./install_gotools.sh

./install_pytools.sh

nvim --headless "+Lazy! sync" +qa
# nvim --headless +qa
# nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

exit 0

