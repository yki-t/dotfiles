use crate::models::HookInput;
use crate::services::{path, shell};
use crate::utils::log_debug;
use anyhow::Result;
use std::path::Path;

const BLOCKED_TOOLS: &[&str] = &["Edit", "Write", "NotebookEdit", "MultiEdit"];

pub fn handle_swarm_guard(input: &HookInput) -> Result<()> {
    let tool_name = match input.tool_name.as_deref() {
        Some(name) => name,
        None => return Ok(()),
    };

    let tool_input = input.tool_input.as_ref();
    let file_path = tool_input.and_then(|ti| ti.file_path.as_deref());
    let command = tool_input.and_then(|ti| ti.command.as_deref());

    log_debug(&format!(
        "SwarmGuard: tool={}, agent_id={:?}, file_path={:?}, command={:?}",
        tool_name, input.agent_id, file_path, command
    ));

    // Create swarm flag when main agent spawns a sub-agent
    if tool_name == "Agent" {
        let flag = format!("/tmp/claude-swarm-{}", input.session_id);
        let _ = std::fs::File::create(&flag);
        log_debug(&format!("SwarmGuard: created swarm flag {}", flag));

        // Worktree agents must include CLAUDE.md's Git Worktree instructions if present
        if let Some(ti) = tool_input {
            if ti.isolation.as_deref() == Some("worktree") {
                validate_worktree_prompt(ti.prompt.as_deref(), input.cwd.as_deref())?;
            }
        }
    }

    // MainAgent: block Edit/Write/NotebookEdit/MultiEdit
    if input.agent_id.is_none() {
        if BLOCKED_TOOLS.contains(&tool_name) {
            return Err(anyhow::anyhow!(
                "Main agent cannot use {tool_name} during swarm workflow. Delegate to sub-agents with git worktree."
            ));
        }
        return Ok(());
    }

    // SubAgent: block file edits outside /tmp/ and .claude/worktrees/
    let cwd = input.cwd.as_deref();

    if BLOCKED_TOOLS.contains(&tool_name) {
        match file_path {
            Some(fp) => path::ensure_path_in_sandbox(fp, cwd, tool_name)?,
            None => return Err(anyhow::anyhow!(
                "Sub-agent used {tool_name} without a file_path; blocked by swarm guard."
            )),
        }
    }

    // Bash: best-effort detection via extract_target_file_from_bash.
    // Only catches >, >>, | tee, curl -o, wget -O patterns.
    // Other write methods (cp, mv, sed -i, etc.) are not detected.
    if tool_name == "Bash" {
        if let Some(cmd) = command {
            if let Some(target) = shell::extract_target_file_from_bash(cmd) {
                path::ensure_path_in_sandbox(&target, cwd, "Bash")?;
            }
        }
    }

    Ok(())
}

fn validate_worktree_prompt(prompt: Option<&str>, cwd: Option<&str>) -> Result<()> {
    let cwd = match cwd {
        Some(c) => c,
        None => return Ok(()),
    };

    let claude_md = Path::new(cwd).join("CLAUDE.md");
    if !claude_md.exists() {
        return Ok(());
    }

    let content = std::fs::read_to_string(&claude_md).unwrap_or_default();
    if !content.contains("Git Worktree") {
        return Ok(());
    }

    let prompt = prompt.unwrap_or("");
    let prompt_lower = prompt.to_lowercase();
    if !prompt_lower.contains("docker compose") && !prompt_lower.contains("docker-compose") {
        return Err(anyhow::anyhow!(
            "CLAUDE.md has a Git Worktree section with container setup instructions. \
             Worktree sub-agent prompts must include docker compose setup procedures \
             (docker-compose.override.yml, port offsets, docker compose up -d)."
        ));
    }

    Ok(())
}
