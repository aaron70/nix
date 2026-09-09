#!/bin/zsh

type="d"
while getopts fd flags; do
  case $flags in
    f) type="f" ;;
    d) type="d" ;;
    *) echo "Invalid arg" && exit 1 ;;
  esac
done

CD_FZF_PATHS=("$HOME/" "$HOME/.config" "$(pwd):5")

if [ -n "$CD_FZF_EXTRA_PATHS" ]; then
  read -ra _extra_paths <<< "$CD_FZF_EXTRA_PATHS"
  CD_FZF_PATHS+=("${_extra_paths[@]}")
fi

find_paths() {
for entry in "${CD_FZF_PATHS[@]}"; do
  if [[ "$entry" =~ ^([^:]+):([0-9]+)$ ]]; then
    path="${BASH_REMATCH[1]}"
    depth="${BASH_REMATCH[2]}"
  else
    path="$entry"
  fi

  [[ -e "$path" ]] && fd . "$path" --max-depth "${depth:-1}" --type "$type" #2>/dev/null
done
}

find_paths | sort -u
