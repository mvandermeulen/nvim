#!/usr/bin/zsh


echo "+ Starting neovim configuration setup."

export NEOVIM_CONFIG_DIR="$HOME/.config/nvim";

HOME_LOCAL_DIRS=("bin" "docs" "include" "lib" "log" "man" "pipx" "share" "src" "state" "tmp" "share/marks/config" "share/nvim" "state/nvim")

for item in $HOME_LOCAL_DIRS[@]; do
  LOCAL_DIR_FP="${HOME}/.local/${item}"
  if [[ ! -d "${LOCAL_DIR_FP}" ]]; then
    echo "+ Creating directory: ${LOCAL_DIR_FP}"
    mkdir -pv "${LOCAL_DIR_FP}"
  fi
done

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

./install_gotools.sh

./install_pytools.sh

nvim --headless "+Lazy! sync" +qa
# nvim --headless +qa
# nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

exit 0

