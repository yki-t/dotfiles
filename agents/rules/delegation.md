# Delegation

## Scope

What the main agent does itself, and what it gives to a sub-agent.
For edits, follow Sub-agent Workflow. This file covers everything else.

## The main agent does

- Decides what to do, in what order, and asks the user for approval.
- Runs `git status`, `git diff`, `git add`, `git commit`.
- Reports to the user.

## The main agent delegates

| Work | Agent |
|---|---|
| Any question that needs a search, a file read, a git history lookup, a log query, or a remote command | `investigator` |
| Reading a known file, line range, or pattern | `file-reader`, through `investigator` |
| Waiting for a CI run, a background task, or a deploy | `Monitor` tool, or a sub-agent |

There is no minimum size. Delegate a single lookup too.

## Why

Each main-agent turn is charged the whole context of that session. A search that
takes 5 turns in the main agent costs 5 times the context; the same search in a
sub-agent costs 1 turn plus the answer.

cc-rein blocks these commands in the main agent. A blocked call still costs a
turn, so delegate first instead of running the command and waiting for the block.
