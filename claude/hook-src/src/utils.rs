use std::fs::OpenOptions;
use std::io::Write;

pub fn log_debug(message: &str) {
    if let Ok(mut file) = OpenOptions::new()
        .create(true)
        .append(true)
        .open(format!("/tmp/claude_hook_debug_{}.log", std::process::id()))
    {
        let _ = writeln!(file, "[{}] {}", chrono::Utc::now().to_rfc3339(), message);
    }
}

pub fn validate_todo_format(content: &str) -> Result<(), String> {
    let lines: Vec<&str> = content.lines().collect();
    
    // Check 1: Title must contain "TODO"
    let has_todo_title = lines.iter()
        .take(5) // Check first 5 lines for title
        .any(|line| line.starts_with('#') && line.contains("TODO"));
    
    if !has_todo_title {
        return Err("TODO file must have a title containing 'TODO'".to_string());
    }
    
    // Check 2: No multi-line code blocks
    if content.contains("```") {
        // Find the line number for better error reporting
        for (idx, line) in lines.iter().enumerate() {
            if line.contains("```") {
                return Err(format!("Multi-line code blocks are not allowed (line {})", idx + 1));
            }
        }
    }
    
    // Check 3: Each top-level task must have at least one sub-item
    let mut current_task_line: Option<usize> = None;
    let mut has_sub_item = false;
    
    for (idx, line) in lines.iter().enumerate() {
        let trimmed = line.trim();
        let indent_level = line.len() - line.trim_start().len();
        
        // Check if it's a top-level task (no indentation)
        if indent_level == 0 && trimmed.starts_with("- [") {
            // If we had a previous task, check if it had sub-items
            if let Some(task_line) = current_task_line {
                if !has_sub_item {
                    return Err(format!(
                        "Task at line {} must have at least one sub-task", 
                        task_line + 1
                    ));
                }
            }
            
            // Start tracking new task
            current_task_line = Some(idx);
            has_sub_item = false;
        } 
        // Check if it's a sub-item (indented)
        else if indent_level > 0 && trimmed.starts_with("- [") {
            has_sub_item = true;
        }
    }
    
    // Check the last task
    if let Some(task_line) = current_task_line {
        if !has_sub_item {
            return Err(format!(
                "Task at line {} must have at least one sub-task", 
                task_line + 1
            ));
        }
    }
    
    Ok(())
}

pub fn extract_target_file_from_bash(command: &str) -> Option<String> {
    // Extract target filename from bash writing commands
    // Returns None if no writing operation is detected
    
    // Check for output redirection operators
    if let Some(pos) = command.find(" > ") {
        let after = command[pos + 3..].trim_start();
        if !after.is_empty() && !after.starts_with('$') && !after.starts_with('&') {
            // Extract filename (handle quotes)
            return extract_filename(after);
        }
    }
    
    if let Some(pos) = command.find(" >> ") {
        let after = command[pos + 4..].trim_start();
        if !after.is_empty() && !after.starts_with('$') && !after.starts_with('&') {
            return extract_filename(after);
        }
    }
    
    // Check for tee command
    if let Some(pos) = command.find("| tee ") {
        let after = command[pos + 6..].trim_start();
        return extract_filename(after);
    }
    
    if let Some(pos) = command.find("|tee ") {
        let after = command[pos + 5..].trim_start();
        return extract_filename(after);
    }
    
    // Check for specific commands with output options
    let patterns = [
        ("curl -o ", 8),
        ("curl --output ", 14),
        ("wget -O ", 8),
        ("wget --output-document ", 23),
    ];
    
    for (pattern, offset) in patterns {
        if let Some(pos) = command.find(pattern) {
            let after = command[pos + offset..].trim_start();
            return extract_filename(after);
        }
    }
    
    None
}

fn extract_filename(s: &str) -> Option<String> {
    // Handle quoted filenames
    if s.starts_with('"') {
        if let Some(end) = s[1..].find('"') {
            return Some(s[1..1+end].to_string());
        }
    } else if s.starts_with('\'') {
        if let Some(end) = s[1..].find('\'') {
            return Some(s[1..1+end].to_string());
        }
    } else {
        // Unquoted filename - take until space or pipe
        let end = s.find(' ').unwrap_or(s.len());
        let end = s[..end].find('|').unwrap_or(end);
        if end > 0 {
            return Some(s[..end].to_string());
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_validate_todo_format_valid() {
        let content = "# TODO List\n- [ ] Main task\n    - [ ] Sub task 1\n    - [ ] Sub task 2";
        assert!(validate_todo_format(content).is_ok());
    }

    #[test]
    fn test_validate_todo_format_no_title() {
        let content = "# List\n- [ ] Task";
        assert!(validate_todo_format(content).is_err());
    }

    #[test]
    fn test_validate_todo_format_with_code_block() {
        let content = "# TODO List\n```python\nprint('hello')\n```";
        let result = validate_todo_format(content);
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("Multi-line code blocks"));
    }

    #[test]
    fn test_validate_todo_format_task_without_subtask() {
        let content = "# TODO List\n- [ ] Task without subtasks\n- [ ] Another task";
        let result = validate_todo_format(content);
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("must have at least one sub-task"));
    }

    #[test]
    fn test_validate_todo_format_single_backtick_allowed() {
        let content = "# TODO List\n- [ ] Task with `code`\n    - [ ] Sub task";
        assert!(validate_todo_format(content).is_ok());
    }

    #[test]
    fn test_extract_target_file_redirect() {
        assert_eq!(
            extract_target_file_from_bash("echo hello > test.txt"),
            Some("test.txt".to_string())
        );
        assert_eq!(
            extract_target_file_from_bash("echo hello >> test.txt"),
            Some("test.txt".to_string())
        );
    }

    #[test]
    fn test_extract_target_file_quoted() {
        assert_eq!(
            extract_target_file_from_bash("echo hello > \"my file.txt\""),
            Some("my file.txt".to_string())
        );
        assert_eq!(
            extract_target_file_from_bash("echo hello > 'my file.txt'"),
            Some("my file.txt".to_string())
        );
    }

    #[test]
    fn test_extract_target_file_tee() {
        assert_eq!(
            extract_target_file_from_bash("echo hello | tee output.log"),
            Some("output.log".to_string())
        );
        assert_eq!(
            extract_target_file_from_bash("echo hello |tee output.log"),
            Some("output.log".to_string())
        );
    }

    #[test]
    fn test_extract_target_file_curl_wget() {
        assert_eq!(
            extract_target_file_from_bash("curl -o output.html https://example.com"),
            Some("output.html".to_string())
        );
        assert_eq!(
            extract_target_file_from_bash("wget -O output.html https://example.com"),
            Some("output.html".to_string())
        );
    }

    #[test]
    fn test_extract_target_file_no_write() {
        assert_eq!(extract_target_file_from_bash("ls -la"), None);
        assert_eq!(extract_target_file_from_bash("cat file.txt"), None);
        assert_eq!(extract_target_file_from_bash("grep pattern file.txt"), None);
    }

    #[test]
    fn test_extract_target_file_complex_commands() {
        assert_eq!(
            extract_target_file_from_bash("echo 'test' > /tmp/TODO_test.md"),
            Some("/tmp/TODO_test.md".to_string())
        );
        assert_eq!(
            extract_target_file_from_bash("cat input.txt | sed 's/old/new/g' > output.txt"),
            Some("output.txt".to_string())
        );
    }

    #[test]
    fn test_extract_filename() {
        assert_eq!(extract_filename("test.txt"), Some("test.txt".to_string()));
        assert_eq!(extract_filename("\"test.txt\""), Some("test.txt".to_string()));
        assert_eq!(extract_filename("'test.txt'"), Some("test.txt".to_string()));
        assert_eq!(extract_filename("test.txt | grep foo"), Some("test.txt".to_string()));
        assert_eq!(extract_filename("test.txt && echo done"), Some("test.txt".to_string()));
    }
}