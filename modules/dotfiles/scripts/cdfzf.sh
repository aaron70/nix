#!/bin/zsh

if [ $# -eq 0 ]; then
  selected_path=$(hydrate-paths | fzf --preview 'custom-fzf-preview {}')
elif [[ $# -eq 1 && "$1" == "-f" ]]; then
  selected_path=$(dirname "$(hydrate-paths -f | fzf --preview 'custom-fzf-preview {}')")
elif [[ $# -eq 1 && ("$1" == "-" || "$1" == "." || "$1" == "..") ]]; then
  selected_path="$*"
else
  if [ ! -e "$*" ] && output=$( zoxide query "$@" 2>/dev/null); then
    selected_path="$output"
  else
    selected_path="$*"
  fi
fi

builtin cd "$selected_path" 
