#!/usr/bin/env zsh

if [[ -f .claude-mode ]] && [[ "$(< .claude-mode)" =~ '^\s*swarm\s*$' ]]; then
  claude --dangerously-skip-permissions \
    --system-prompt "$(cat ~/dotfiles/claude/swarm/prompt.txt)" \
    --setting-sources "user" \
    --settings ~/dotfiles/claude/swarm/settings.json \
    "$@"
else
  claude --dangerously-skip-permissions "$@"
fi
