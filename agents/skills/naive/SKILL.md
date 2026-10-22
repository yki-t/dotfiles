---
name: naive
description: Default Claude Code behavior. The rules, custom sub-agents, and skill workflows in this configuration do not apply
disable-model-invocation: true
---

# Scope

Follow only the Claude Code system prompt and the user's instructions.

The following do not apply while this skill runs:
- All rules in `~/.claude/rules/`
- The custom sub-agents in `~/.claude/agents/` (`investigator`, `file-reader`, `subagents-checker`, `code-reviewer`)
- The workflows of other skills

Research, file reads, edits, and sub-agent use follow the default judgment of Claude Code.

# Exit

When the user ends naive mode, run `cc-rein skill end` with Bash.
