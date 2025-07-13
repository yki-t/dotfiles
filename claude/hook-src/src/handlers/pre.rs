use crate::models::HookInput;
use crate::utils::{log_debug, extract_target_file_from_bash, validate_todo_format};
use anyhow::Result;
use std::path::Path;

pub fn handle_pre_tool_use(input: &HookInput) -> Result<()> {
    let tool_name = input.tool_name.as_str();
    let file_path = input.tool_input.file_path.as_deref();
    let command = input.tool_input.command.as_deref();

    log_debug(&format!(
            "PreToolUse: tool={}, file_path={:?}, command={:?}",
            tool_name, file_path, command
    ));

    // Tool-specific checks
    // NOTE: Tool Names: Write|Edit|MultiEdit|Read|Bash|Grep|Glob|LS|Task|TodoWrite|WebSearch|WebFetch

    // Block WebSearch
    if tool_name == "WebSearch" {
        return Err(anyhow::anyhow!("Use `gemini -p 'WebSearch: SEARCH_TEXT'` instead of `WebSearch`"));
    }

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
        let name = p.file_name().and_then(|n| n.to_str()).unwrap_or("");

        // Block .sh files
        if ext == "sh" {
            return Err(anyhow::anyhow!("Creating or editing .sh files is prohibited"));
        }

        // Block .md files (except TODO.md)
        if ext == "md" && name != "TODO.md" {
            return Err(anyhow::anyhow!("Creating or editing .md files is prohibited"));
        }

        // Validate TODO file format when writing
        if ext == "md" && name == "TODO.md" && is_file_writing_tool {
            // Get content from tool_input.other["content"]
            if let Some(content_value) = input.tool_input.other.get("content") {
                if let Some(content) = content_value.as_str() {
                    if let Err(e) = validate_todo_format(content) {
                        return Err(anyhow::anyhow!("Invalid TODO format: {}", e));
                    }
                }
            }
        }
    }

    // Additional bash command checks
    if tool_name == "Bash" {
        if let Some(cmd) = command {
            if cmd.contains("git commit") {
                return Err(anyhow::anyhow!("git commit is prohibited"));
            }
        }
    }

    Ok(())
}