use crate::models::HookInput;
use crate::utils::{log_debug, extract_target_file_from_bash, validate_todo_format};
use anyhow::Result;
use std::env;
use std::path::Path;
use std::fs;

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

    // Check if TODO.md creation should be enforced
    let skip_todo_check = env::var("CLAUDE_HOOK_SKIP_TODO")
        .map(|v| v.to_lowercase() == "true" || v == "1")
        .unwrap_or(false);

    // For code editing tools, check if TODO.md exists (unless check is skipped)
    if is_file_writing_tool && !skip_todo_check {
        // Check if the file being written is TODO.md itself
        let is_todo_file = file_path
            .and_then(|p| Path::new(p).file_name())
            .and_then(|n| n.to_str())
            .map(|name| name == "TODO.md")
            .unwrap_or(false);

        // If not writing TODO.md, check if TODO.md exists
        if !is_todo_file {
            // Check in current directory and project root
            let todo_exists = fs::metadata("TODO.md").is_ok() || 
                              fs::metadata("./TODO.md").is_ok() ||
                              env::current_dir()
                                  .ok()
                                  .and_then(|dir| fs::metadata(dir.join("TODO.md")).ok())
                                  .is_some();

            if !todo_exists {
                return Err(anyhow::anyhow!("Read CLAUDE.md before starting any tasks. Must create TODO.md before implementation"));
            }
        }
    }

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

        if is_file_writing_tool {
            // Check environment variable for .sh files permission
            let allow_sh = env::var("CLAUDE_HOOK_ALLOW_SH")
                .map(|v| v.to_lowercase() == "true" || v == "1")
                .unwrap_or(false);
            
            // Block .sh files (unless explicitly allowed)
            if ext == "sh" && !allow_sh {
                return Err(anyhow::anyhow!("Creating or editing ad hoc .sh files is prohibited"));
            }

            // Check environment variable for .md files permission
            let allow_md = env::var("CLAUDE_HOOK_ALLOW_MD")
                .map(|v| v.to_lowercase() == "true" || v == "1")
                .unwrap_or(false);

            // Block .md files (except TODO.md, or if explicitly allowed)
            if ext == "md" && !allow_md {
                if name != "TODO.md" && name != "README.md" {
                    return Err(anyhow::anyhow!("Creating or editing .md document files is prohibited"));
                }

                if name == "TODO.md" {
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