set -euo pipefail

if [ "${HERDR_ENV:-}" != "1" ]; then
  echo "Can't open the prime workspace. You're not currently in a Herdr session." >&2
  exit 1
fi

workspace_id="${HERDR_WORKSPACE_ID:-}"
if [ -z "$workspace_id" ]; then
  workspace_id=$(herdr workspace list | jq -r '[.result.workspaces[] | select(.focused)][0].workspace_id // empty')
fi

if [ -z "$workspace_id" ]; then
  echo "Can't open the prime workspace. No Herdr workspace could be resolved." >&2
  exit 1
fi

if ! workspace_json=$(herdr workspace get "$workspace_id" 2>/dev/null); then
  echo "Can't open the prime workspace. Herdr workspace '$workspace_id' was not found." >&2
  exit 1
fi

current_id=$(jq -r '.result.workspace.workspace_id' <<<"$workspace_json")
current_label=$(jq -r '.result.workspace.label' <<<"$workspace_json")
prime_parent=$(jq -r '.result.workspace.tokens.prime_parent // empty' <<<"$workspace_json")

focus_workspace() {
  herdr workspace focus "$1" >/dev/null
}

mark_prime() {
  herdr workspace report-metadata "$1" \
    --source toggle-herdr-popup \
    --token prime_parent="$2" >/dev/null 2>&1 || true
}

# Already in a prime workspace: go back to its parent and leave it running.
if [ -n "$prime_parent" ]; then
  if focus_workspace "$prime_parent"; then
    exit 0
  fi

  echo "Can't leave prime workspace '$current_label'. Parent workspace '$prime_parent' is no longer available." >&2
  exit 1
fi

# Support prime workspaces created before the parent token was recorded.
case "$current_label" in
  *"'" )
    parent_label="${current_label%\'}"
    parent_id=$(herdr workspace list | jq -r --arg label "$parent_label" '
      [.result.workspaces[] | select(.label == $label)][0].workspace_id // empty
    ')

    if [ -z "$parent_id" ]; then
      echo "Can't leave prime workspace '$current_label'. Workspace '$parent_label' was not found." >&2
      exit 1
    fi

    mark_prime "$current_id" "$parent_id"
    focus_workspace "$parent_id"
    exit 0
    ;;
esac

prime_label="${current_label}'"
prime_id=$(herdr workspace list | jq -r --arg parent "$current_id" --arg label "$prime_label" '
  [.result.workspaces[] | select(
    ((.tokens.prime_parent // "") != "" and .tokens.prime_parent == $parent)
    or ((.tokens.prime_parent // "") == "" and .label == $label)
  )][0].workspace_id // empty
')

if [ -z "$prime_id" ]; then
  prime_json=$(herdr workspace create --cwd "$PWD" --label "$prime_label" --focus)
  prime_id=$(jq -r '.result.workspace.workspace_id' <<<"$prime_json")
else
  focus_workspace "$prime_id"
fi

mark_prime "$prime_id" "$current_id"

