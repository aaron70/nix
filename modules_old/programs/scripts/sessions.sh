session=$(sesh list -i | grep -v "^.*'$" | fzf-tmux -p 75%,75% \
  --prompt " " --ansi \
  --header '  ^a all ^h hydrate-paths ^t tmux ^x zoxide ^g config ^d tmux kill ^f find' \
  --bind 'tab:down,btab:up' \
  --bind 'ctrl-a:reload({ (sesh list | grep -v "^.*'"'"'$") & hydrate-paths; wait;})' \
  --bind 'ctrl-h:reload(hydrate-paths)' \
  --bind 'ctrl-t:reload(sesh list -it | grep -v "^.*'"'"'$")' \
  --bind 'ctrl-g:reload(sesh list -ic | grep -v "^.*'"'"'$")' \
  --bind 'ctrl-x:reload(sesh list -iz | grep -v "^.*'"'"'$")' \
  --bind 'ctrl-f:reload(fd -H -d 2 -t d -E .Trash . ~)' \
  --bind 'ctrl-d:execute(tmux kill-session -t {})+reload(sesh list | grep -v "^.*'"'"'$")'
)

if [ "$session" != "" ]; then
  sesh connect $session 
fi
