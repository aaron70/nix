if [ -z "$TMUX" ]; then
  echo "Can't open the popup pane. You're not currently on a tmux session."
  exit 1
fi

command="tmux new-session -A -s \"$(tmux display-message -p "#S")'\""
id="0"
if [ -n "$1" ]; then
  command="$1"
  id=$(echo "$command" | sha512sum | cut -d ' ' -f 1)
fi

if [ -n "$TMUX_IS_POPUP" ]; then
  tmux detach
  if [ "$TMUX_POPUP_ID" == "$id" ]; then
    exit
  fi
fi

if [ -n "$1" ]; then
  tmux popup \
    -E \
    -d "#{pane_current_path}" \
    -w "80%" -h "80%" \
    -T "Floating Pane" \
    -e TMUX_IS_POPUP="1" \
    -e TMUX_POPUP_ID="$id" \
    "$command"
else
  tmux popup \
    -E \
    -d "#{pane_current_path}" \
    -w "80%" -h "80%" \
    -T "Floating Pane" \
    "$command -e TMUX_IS_POPUP=1 -e TMUX_POPUP_ID=\"$id\""
fi
