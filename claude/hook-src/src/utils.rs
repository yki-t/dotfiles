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
    
    // Check 3: First task must be about getting user approval
    let mut found_first_task = false;
    for line in lines.iter() {
        let trimmed = line.trim();
        let indent_level = line.len() - line.trim_start().len();
        
        // Check if it's a top-level task (no indentation)
        if indent_level == 0 && trimmed.starts_with("- [") {
            found_first_task = true;
            let task_content = trimmed.to_lowercase();
            
            // Check if first task mentions approval/review/承認
            if !task_content.contains("approval") && 
               !task_content.contains("approve") &&
               !task_content.contains("review") &&
               !task_content.contains("承認") &&
               !task_content.contains("確認") &&
               !task_content.contains("レビュー") {
                return Err(
                    "The first task must be about getting user approval or review. \
                    Example: '- [ ] Get user approval for this TODO list' or \
                    '- [ ] このTODOリストのユーザー承認を取得'".to_string()
                );
            }
            break;
        }
    }
    
    if !found_first_task {
        return Err("TODO file must contain at least one task".to_string());
    }
    
    // Note: Removed the check for sub-tasks requirement
    // Tasks can now exist without sub-tasks
    
    // Check 4: No empty header blocks (headers without content)
    // A header is empty if there's no content before the next header at the same or higher level
    let mut i = 0;
    while i < lines.len() {
        let line = lines[i];
        let trimmed = line.trim();
        
        if trimmed.starts_with('#') {
            let header_level = trimmed.chars().take_while(|&c| c == '#').count();
            let header_text = trimmed[header_level..].trim();
            
            // Skip the main TODO title
            if header_level == 1 && header_text.contains("TODO") {
                i += 1;
                continue;
            }
            
            // Look for content after this header
            let mut has_content = false;
            let mut j = i + 1;
            
            while j < lines.len() {
                let next_line = lines[j];
                let next_trimmed = next_line.trim();
                
                // If we hit another header
                if next_trimmed.starts_with('#') {
                    let next_level = next_trimmed.chars().take_while(|&c| c == '#').count();
                    // If the next header is at the same or higher level (lower number), stop
                    if next_level <= header_level {
                        break;
                    }
                    // Otherwise, this is a sub-header, which counts as content
                    has_content = true;
                    break;
                }
                // If we find a task (only tasks count as content, not text)
                else if next_trimmed.starts_with("- [") {
                    has_content = true;
                    break;
                }
                // Text-only lines do not count as content
                
                j += 1;
            }
            
            if !has_content {
                return Err(format!(
                    "Empty header block found at line {}: '{}' has no content underneath",
                    i + 1,
                    "#".repeat(header_level) + " " + &header_text
                ));
            }
        }
        
        i += 1;
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
        let content = "# TODO List\n- [ ] Get user approval for this TODO list\n    - [ ] Review the plan\n- [ ] Main task";
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
    fn test_validate_todo_format_task_without_approval() {
        let content = "# TODO List\n- [ ] First task\n- [ ] Another task";
        let result = validate_todo_format(content);
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("must be about getting user approval"));
    }

    #[test]
    fn test_validate_todo_format_task_without_subtask_allowed() {
        let content = "# TODO List\n- [ ] Get user approval\n- [ ] Task without subtasks";
        assert!(validate_todo_format(content).is_ok());
    }

    #[test]
    fn test_validate_todo_format_single_backtick_allowed() {
        let content = "# TODO List\n- [ ] Get user approval with `code`\n    - [ ] Sub task";
        assert!(validate_todo_format(content).is_ok());
    }

    #[test]
    fn test_validate_todo_format_empty_header_block() {
        // Test empty ## header
        let content = "# TODO List\n- [ ] Get user approval\n## Empty Section\n## Another Section\n- [ ] Task";
        let result = validate_todo_format(content);
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("Empty header block"));
        
        // Test empty ### header at end of file
        let content2 = "# TODO List\n- [ ] Get user approval\n- [ ] Task at root level\n### Empty Subsection";
        let result2 = validate_todo_format(content2);
        assert!(result2.is_err());
        assert!(result2.unwrap_err().contains("Empty header block"));
    }

    #[test]
    fn test_validate_todo_format_header_with_content_ok() {
        // Header followed by task is OK
        let content = "# TODO List\n- [ ] Get user approval\n## Section with content\n- [ ] Task under section\n### Subsection\n- [ ] Task under subsection";
        assert!(validate_todo_format(content).is_ok());
        
        // Nested headers are OK as long as they have content
        let content2 = "# TODO List\n- [ ] Get user approval\n## Level 2\n### Level 3\n- [ ] Task at level 3";
        assert!(validate_todo_format(content2).is_ok());
    }

    #[test]
    fn test_validate_todo_format_empty_header_at_end() {
        // Empty header at the end of file
        let content = "# TODO List\n- [ ] Get user approval\n- [ ] Another task\n## Empty at End";
        let result = validate_todo_format(content);
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("Empty header block"));
    }

    #[test]
    fn test_validate_todo_format_multiple_empty_headers() {
        let content = "# TODO List\n- [ ] Get user approval\n## Empty 1\n### Empty 2\n#### Empty 3";
        let result = validate_todo_format(content);
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("Empty header block"));
    }

    #[test]
    fn test_validate_todo_format_header_with_text_only() {
        // Header with only text (no tasks) should be considered empty
        let content = "# TODO List\n- [ ] Get user approval\n## Description Section\nThis is some descriptive text\nMore text here\n## Task Section\n- [ ] Task";
        let result = validate_todo_format(content);
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("Empty header block"));
        
        // Header with task is OK
        let content2 = "# TODO List\n- [ ] Get user approval\n## Section with Task\n- [ ] Task under section";
        assert!(validate_todo_format(content2).is_ok());
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