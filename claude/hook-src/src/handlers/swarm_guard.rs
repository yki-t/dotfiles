use crate::models::HookInput;
use anyhow::Result;

const BLOCKED_TOOLS: &[&str] = &["Edit", "Write", "NotebookEdit"];

pub fn handle_swarm_guard(input: &HookInput) -> Result<()> {
    if input.agent_id.is_some() {
        return Ok(());
    }

    let tool_name = match input.tool_name.as_deref() {
        Some(name) => name,
        None => return Ok(()),
    };

    if BLOCKED_TOOLS.contains(&tool_name) {
        return Err(anyhow::anyhow!(
            "Main agent cannot use {tool_name} during swarm workflow. Delegate to sub-agents with git worktree."
        ));
    }

    Ok(())
}
