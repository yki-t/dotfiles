use crate::models::HookInput;
use anyhow::Result;

pub fn handle_post_tool_use(_input: &HookInput) -> Result<()> {
    Ok(())
}