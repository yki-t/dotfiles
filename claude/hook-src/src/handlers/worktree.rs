use crate::models::HookInput;
use crate::utils::log_debug;
use anyhow::{anyhow, Result};
use std::process::Command;

pub fn handle_worktree_create(input: &HookInput) -> Result<String> {
    let name = input
        .name
        .as_deref()
        .ok_or_else(|| anyhow!("WorktreeCreate: missing 'name' field"))?;

    if name.contains('/') || name.contains("..") || name.contains('\0') {
        return Err(anyhow!("Invalid worktree name: {name}"));
    }

    let cwd = input
        .cwd
        .as_deref()
        .ok_or_else(|| anyhow!("WorktreeCreate: missing 'cwd' field"))?;

    let path = format!("{cwd}/.claude/worktrees/{name}");
    let branch = format!("claude/worktrees/{name}");

    log_debug(&format!(
        "WorktreeCreate: name={}, cwd={}, path={}, branch={}",
        name, cwd, path, branch
    ));

    // Redirect git's stdout to stderr so only the path goes to stdout
    let stderr_for_stdout = std::process::Stdio::from(std::io::stderr());

    let status = Command::new("git")
        .args(["-C", cwd, "worktree", "add", "-b", &branch, &path, "HEAD"])
        .stdout(stderr_for_stdout)
        .stderr(std::process::Stdio::inherit())
        .status()
        .map_err(|e| anyhow!("Failed to run git worktree add: {e}"))?;

    if !status.success() {
        return Err(anyhow!("git worktree add failed with {status}"));
    }

    log_debug(&format!("WorktreeCreate: successfully created {}", path));

    Ok(path)
}

pub fn handle_worktree_remove(input: &HookInput) -> Result<()> {
    let worktree_path = input
        .worktree_path
        .as_deref()
        .ok_or_else(|| anyhow!("WorktreeRemove: missing 'worktree_path' field"))?;
    let cwd = input
        .cwd
        .as_deref()
        .ok_or_else(|| anyhow!("WorktreeRemove: missing 'cwd' field"))?;

    log_debug(&format!(
        "WorktreeRemove: worktree_path={}, cwd={}",
        worktree_path, cwd
    ));

    let status = Command::new("git")
        .args(["-C", cwd, "worktree", "remove", "--force", worktree_path])
        .status()
        .map_err(|e| anyhow!("Failed to run git worktree remove: {e}"))?;

    if !status.success() {
        return Err(anyhow!("git worktree remove failed with {status}"));
    }

    // Best-effort branch cleanup: derive branch name from worktree path
    let branch_name = worktree_path
        .find(".claude/worktrees/")
        .map(|idx| &worktree_path[idx + ".claude/worktrees/".len()..])
        .map(|name| format!("claude/worktrees/{name}"));

    if let Some(branch) = &branch_name {
        log_debug(&format!("WorktreeRemove: deleting branch {}", branch));
        let _ = Command::new("git")
            .args(["-C", cwd, "branch", "-D", branch])
            .status();
    }

    log_debug(&format!(
        "WorktreeRemove: successfully removed {}",
        worktree_path
    ));

    Ok(())
}
