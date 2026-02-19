use crate::models::HookInput;
use crate::utils::{extract_target_file_from_bash, log_debug};
use anyhow::Result;
use std::env;
use std::path::Path;

pub fn handle_pre_tool_use(input: &HookInput) -> Result<()> {
    let tool_name = input.tool_name.as_str();
    let file_path = input.tool_input.file_path.as_deref();
    let command = input.tool_input.command.as_deref();

    log_debug(&format!(
            "PreToolUse: tool={}, file_path={:?}, command={:?}",
            tool_name, file_path, command
    ));

    // Check file writing operations (both direct and via bash)
    let is_file_writing_tool = matches!(tool_name, "Write" | "Edit" | "MultiEdit");

    // Get target path from either direct file operations or bash commands
    let bash_target = if tool_name == "Bash" {
        command.and_then(|cmd| extract_target_file_from_bash(cmd))
    } else {
        None
    };

    let target_path = if is_file_writing_tool {
        file_path
    } else {
        bash_target.as_deref()
    };

    if let Some(path) = target_path {
        let p = Path::new(path);
        let ext = p.extension().and_then(|e| e.to_str()).unwrap_or("");

        if is_file_writing_tool {
            let ch_allow = env::var("CH_ALLOW")
                .unwrap_or_default()
                .to_ascii_lowercase();
            let allowed: Vec<&str> = ch_allow
                .split(',')
                .map(|s| s.trim())
                .filter(|s| !s.is_empty())
                .collect();

            let allow_all = allowed.contains(&"all");

            // Block .sh files (unless explicitly allowed)
            if ext == "sh" && !allow_all && !allowed.contains(&"sh") {
                return Err(anyhow::anyhow!("Creating or editing ad hoc .sh files is prohibited"));
            }

            // Block .md files (unless explicitly allowed)
            if ext == "md" && !allow_all && !allowed.contains(&"md") {
                return Err(anyhow::anyhow!("Creating or editing .md document files is prohibited"));
            }
        }
    }

    Ok(())
}