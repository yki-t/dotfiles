use crate::models::HookInput;
use crate::services::{path, shell};
use crate::utils::log_debug;
use anyhow::Result;

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

    // MainAgent: block Edit/Write/NotebookEdit/MultiEdit
    if input.agent_id.is_none() {
        if BLOCKED_TOOLS.contains(&tool_name) {
            return Err(anyhow::anyhow!(
                "Main agent cannot use {tool_name} during swarm workflow. Delegate to sub-agents with git worktree."
            ));
        }
        return Ok(());
    }

    // SubAgent: block file edits outside /tmp/
    let cwd = input.cwd.as_deref();

    if BLOCKED_TOOLS.contains(&tool_name) {
        match file_path {
            Some(fp) => path::check_subagent_file_path(fp, cwd, tool_name)?,
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
                path::check_subagent_file_path(&target, cwd, "Bash")?;
            }
        }
    }

    Ok(())
}
