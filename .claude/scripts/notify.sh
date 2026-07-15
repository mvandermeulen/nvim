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
source "${SHARED_FUNCTIONS_PATH}/notify.functions.sh" || {
  mylogp "error" "Fatal error loading required notification scripts!"; return 1;
}
source "${SHARED_FUNCTIONS_PATH}/github.functions.sh" || {
  mylogp "error" "Fatal error loading required github scripts!"; return 1;
}
source "${SHARED_FUNCTIONS_PATH}/remote.functions.sh" || {
  mylogp "error" "Fatal error loading required remote scripts!"; return 1;
}
mylog "info" "Running script: ${SCRIPT_NAME}";

input=$(cat);
session_id=$(echo "${input}" | jq -r '.session_id');
transcript_path=$(echo "${input}" | jq -r '.transcript_path');



function get_tmux_session_and_window() {
  local session window;
  session=$(tmux display-message -p '#S' 2>/dev/null);
  window=$(tmux display-message -p '#I:#W' 2>/dev/null);
  echo "${session}:${window}";
  return 0;
}

function get_tmux_pane_directory() {
  local tmux_current_path;
  tmux_current_path=$(tmux display-message -p -F "#{pane_current_path}" 2>/dev/null);
  echo "${tmux_current_path}";
  return 0;
}

[[ -n "${TMUX}" ]] && {
  path=$(get_tmux_pane_directory);
  mylog "info" "Current tmux session and window: $(get_tmux_session_and_window)";
} || {
  path="${PWD}";
  mylog "info" "Not running inside tmux, using current working directory: ${path}";
};


# Usage: send_notification_xplatform <message> [<title>] [<subtitle>]

project_name=$(basename "${path}"); parent=$(dirname "${path}"); project_category=$(basename "${parent}");
subtitle="\[${project_category}/${project_name}]";
summary=$(head -n 1 "${transcript_path}" | jq -r 'select(.type == "user") | .message.content' 2>/dev/null | cut -c 1-50)
if [[ -z "${summary}" || "${summary}" == "null" ]]; then
  message="Agent run complete"
else
  message="${summary}"
fi

on_click="macos_launch_or_focus_app Alacritty";
group_name="claude-${project_name}-${session_id}";

notify_send "${group_name}" "Claude Code" "${subtitle}" "${message}" "${on_click}";

# Usage: notify_send <group_name> <title> <subtitle> <message> <execute_script>

# terminal-notifier \
#   -title "Claude Code" \
#   -subtitle "$subtitle" \
#   -message "$message" \
#   -group "$group_name" \
#   -execute "$on_click" &> /dev/null





