---
name: pr
description: Create a Pull Request against a specified base branch
argument-hint: <base-branch>
---

# pull request

## Task
Create a Pull Request from the current branch against the base branch specified in Arguments.
1. Fetch the base branch with `git fetch origin <base>`
2. Push the current branch with `git push -u origin <head-branch>` when the hash from `git ls-remote --heads origin <head-branch>` differs from `git rev-parse HEAD`
3. Delegate to `investigator`: run `git diff origin/<base>...HEAD` (3 dots; 2 dots includes base-branch commits) and `git log origin/<base>..HEAD`, and return the changes grouped by intent and the commit titles with hashes
4. Draft the PR title and description following the Pull Request section of the Git rules. Ask questions if unclear
5. Get user approval
6. Create the PR with `gh pr create`
7. Monitor CI with the Monitor tool, or delegate the wait to a sub-agent
