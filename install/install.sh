#!/usr/bin/bash
function usage() {
  echo "Usage: install.sh [<options>]"
  echo ""
  echo "Options:"
  echo "    -d, --dependencies                       dependencies"
  echo "    -i, --install                            installing all dependencies"
  echo "    -m, --miniinstall                        minimal installation dependencies"
}
function dependencies() {
  echo "Visual Studio NeoVim All dependencie:"
  echo ""
  echo "  neovim      "
  echo "  lua         "
  echo "  luajit      "
  echo "  python      "
  echo "  npm         "
  echo "  node        "
  echo "  yarn        "
  echo "  python-pip  "
  echo "  lazygit     "
  echo "  tree-sitter "
  echo ""
}
function detect_platform() {
  OS="$(uname -s)"
  case "$OS" in
    Linux)
      if [ -f "/etc/arch-release" ] || [ -f "/etc/artix-release" ]; then
        RECOMMEND_INSTALL="sudo pacman -S --noconfirm"
      elif [ -f "/etc/fedora-release" ] || [ -f "/etc/redhat-release" ]; then
        RECOMMEND_INSTALL="sudo dnf install -y"
      elif [ -f "/etc/gentoo-release" ]; then
        RECOMMEND_INSTALL="emerge install -y"
      else # assume debian based
        RECOMMEND_INSTALL="sudo apt install -y"
      fi
      ;;
    FreeBSD)
      RECOMMEND_INSTALL="sudo pkg install -y"
      ;;
    NetBSD)
      RECOMMEND_INSTALL="sudo pkgin install"
      ;;
    OpenBSD)
      RECOMMEND_INSTALL="doas pkg_add"
      ;;
    Darwin)
      RECOMMEND_INSTALL="brew install"
      ;;
    *)
      echo "OS :$OS is not currently supported."
      exit 1
      ;;
  esac
}
function __installing_neovim() {
  echo "Would you like to install neovim ? (Only if you don't have neovim installed)"
  read -p "[Y]es or [N]o : " answer
  if [[ "$answer" == "Y" || "$answer" == "y" ]]; then
    $RECOMMEND_INSTALL neovim
  fi
  echo ""
}
function __installing_lua() {
  echo "Would you like to install lua and luajit ? (Only if you don't have lua and luaJIT installed)"
  read -p "[Y]es or [N]o : " answer
  if [[ "$answer" == "Y" || "$answer" == "y" ]]; then
    $RECOMMEND_INSTALL luajit
    $RECOMMEND_INSTALL lua || $RECOMMEND_INSTALL lua5.4
  fi
  echo ""
}
function __installing_python() {
  echo "Would you like to install neovim's python librarys ? (Recomended , install only if pynvim is NOT installed)"
  read -p "[Y]es or [N]o : " answer
  if [[ "$answer" == "Y" || "$answer" == "y" ]]; then
    python3 -m pip install pynvim
  fi
  echo ""
}
function __installing_node() {
  echo "Would you like to install node ?"
  read -p "[Y]es or [N]o : " answer
  if [[ "$answer" == "Y" || "$answer" == "y" ]]; then
    $RECOMMEND_INSTALL nodejs npm yarn
  fi
  echo ""
}
function __installing_utils() {
  echo "Would you like to install some recomended utilities ? (treesitter and lazygit) "
  read -p "[Y]es or [N]o : " answer
  if [[ "$answer" == "Y" || "$answer" == "y" ]]; then
    $RECOMMEND_INSTALL lazygit  tree-sitter
  fi
  echo ""
}
function installation() {
  detect_platform
  __installing_neovim
  __installing_lua
  __installing_python
  __installing_node
  __installing_utils
}
function miniinstallation() {
  detect_platform
  __installing_lua
  __installing_python
  __installing_node
}
function cloning_vsneovim() {
  echo "cloning VSNeoVim ..."
  mv $HOME/.config/nvim/ $HOME/.config/NVIM_OLD
  mv $HOME/.local/share/nvim/ $HOME/.local/share/NVIM_OLD
  git clone https://github.com/VSNeovim/VSNeovim ~/.config/nvim
  echo "done cloning !"
}
function parse_arguments() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -d | --dependencies)
        dependencies   
        exit 0
        ;;
      -i | --install)
        installation
        cloning_vsneovim
        ;;
      -m | --miniinstall)
        miniinstallation
        cloning_vsneovim
        exit 0
        ;;
      -h | --help)
        usage
        exit 0
        ;;
    esac
    shift
  done
}
function done() {
  echo "Installing :"
  echo "  dependencies ( ./install.sh -d )"
  echo "Thank you for installing Visual Studio NeoVim :)"
}
function logo(){
  cat <<'EOF'
    
    db    db .d8888.     d8b   db d88888b  .d88b.  db    db d888888b .88b  d88.
    88    88 88'  YP     888o  88 88'     .8P  Y8. 88    88   `88'   88'YbdP`88
    Y8    8P `8bo.       88V8o 88 88ooooo 88    88 Y8    8P    88    88  88  88
    `8b  d8'   `Y8b.     88 V8o88 88~~~~~ 88    88 `8b  d8'    88    88  88  88
     `8bd8'  db   8D     88  V888 88.     `8b  d8'  `8bd8'    .88.   88  88  88
       YP    `8888Y'     VP   V8P Y88888P  `Y88P'     YP    Y888888P YP  YP  YP

                       V i s u a l S t u d i o N e o v i m                     

EOF
}
function main() {
  parse_arguments "$@"
  logo
  installation
  cloning_vsneovim
}
main "$@"

