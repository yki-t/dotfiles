struct BlockedPattern {
    prefix: &'static str,
    reason: &'static str,
}

const BLOCKED_PATTERNS: &[BlockedPattern] = &[
    BlockedPattern {
        prefix: "git push",
        reason: "git push is blocked: remote push must be done manually or user might already push if you are trying to make a PR",
    },
    BlockedPattern {
        prefix: "git reset",
        reason: "git reset is blocked: destructive operation",
    },
    BlockedPattern {
        prefix: "git checkout",
        reason: "git checkout is blocked: use git switch or do it manually",
    },
    BlockedPattern {
        prefix: "git stash",
        reason: "git stash is blocked: stash operations must be done manually",
    },
    BlockedPattern {
        prefix: "git restore",
        reason: "git restore is blocked: working tree modifications not allowed",
    },
    BlockedPattern {
        prefix: "gh pr close",
        reason: "gh pr close is blocked: PR lifecycle must be managed manually",
    },
    BlockedPattern {
        prefix: "terraform apply",
        reason: "terraform apply is blocked: infrastructure changes require manual approval",
    },
    BlockedPattern {
        prefix: "terraform destroy",
        reason: "terraform destroy is blocked: infrastructure destruction requires manual approval",
    },
];

/// Count consecutive backslashes before position `pos`.
/// Returns true if the character at `pos` is escaped (odd number of preceding backslashes).
fn is_escaped(chars: &[char], pos: usize) -> bool {
    let mut count = 0;
    let mut j = pos;
    while j > 0 {
        j -= 1;
        if chars[j] == '\\' {
            count += 1;
        } else {
            break;
        }
    }
    count % 2 == 1
}

/// Check if `text` starts with `prefix` followed by end of string or whitespace.
fn starts_with_command(text: &str, prefix: &str) -> bool {
    if !text.starts_with(prefix) {
        return false;
    }
    match text.as_bytes().get(prefix.len()) {
        None => true,
        Some(b) => b.is_ascii_whitespace(),
    }
}

/// Check for blocked npm run cdk patterns.
fn check_npm_cdk(segment: &str) -> Option<&'static str> {
    let trimmed = segment.trim();
    let rest = trimmed.strip_prefix("npm run")?;
    let rest = rest.trim_start();
    let rest = rest.strip_prefix("--").map_or(rest, |r| r.trim_start());
    if starts_with_command(rest, "cdk deploy") {
        Some("npm run cdk deploy is blocked: CDK deployment requires manual approval")
    } else if starts_with_command(rest, "cdk destroy") {
        Some("npm run cdk destroy is blocked: CDK destruction requires manual approval")
    } else {
        None
    }
}

/// Remove line continuations (backslash-newline) before parsing.
fn strip_line_continuations(command: &str) -> String {
    command.replace("\\\n", "")
}

/// Strip outer quotes from a string (single or double).
fn strip_outer_quotes(s: &str) -> String {
    let s = s.trim();
    if s.len() >= 2 {
        if (s.starts_with('"') && s.ends_with('"'))
            || (s.starts_with('\'') && s.ends_with('\''))
        {
            return s[1..s.len() - 1].to_string();
        }
    }
    s.to_string()
}

/// Detect `sh -c`, `bash -c`, `zsh -c` patterns and extract the argument.
fn extract_shell_c_arg(segment: &str) -> Option<String> {
    let s = segment.trim();
    let shell_names = ["sh", "bash", "zsh"];
    for shell in &shell_names {
        let prefixes = [
            format!("{} -c ", shell),
            format!("/bin/{} -c ", shell),
            format!("/usr/bin/{} -c ", shell),
        ];
        for prefix in &prefixes {
            if let Some(rest) = s.strip_prefix(prefix.as_str()) {
                return Some(strip_outer_quotes(rest));
            }
        }
    }
    None
}

/// Split a shell command string into individual command segments.
///
/// Handles: `&&`, `||`, `&`, `;`, `|`, newlines, `$(...)`, backticks, `<(...)`, `>(...)`.
/// Respects single and double quotes.
fn split_shell_segments(command: &str) -> Vec<String> {
    let chars: Vec<char> = command.chars().collect();
    let len = chars.len();
    let mut segments: Vec<String> = Vec::new();
    let mut current = String::new();
    let mut i = 0;
    let mut in_single_quote = false;
    let mut in_double_quote = false;

    while i < len {
        let c = chars[i];

        // Single quote handling (toggle only when not in double quotes)
        if c == '\'' && !in_double_quote {
            in_single_quote = !in_single_quote;
            current.push(c);
            i += 1;
            continue;
        }

        // Inside single quotes: everything is literal
        if in_single_quote {
            current.push(c);
            i += 1;
            continue;
        }

        // Double quote handling (check for escaped quotes)
        if c == '"' && !in_single_quote {
            if is_escaped(&chars, i) {
                current.push(c);
                i += 1;
                continue;
            }
            in_double_quote = !in_double_quote;
            current.push(c);
            i += 1;
            continue;
        }

        // $(...) — process in both unquoted and double-quoted contexts
        if c == '$' && i + 1 < len && chars[i + 1] == '(' {
            let inner_start = i + 2;
            let mut depth = 1;
            let mut j = inner_start;
            let mut sq = false;
            let mut dq = false;
            while j < len && depth > 0 {
                let ch = chars[j];
                if ch == '\'' && !dq {
                    sq = !sq;
                } else if ch == '"' && !sq {
                    if !is_escaped(&chars, j) {
                        dq = !dq;
                    }
                } else if !sq && !dq {
                    if ch == '(' && j > 0 && chars[j - 1] == '$' {
                        depth += 1;
                    } else if ch == ')' {
                        depth -= 1;
                    }
                }
                j += 1;
            }
            let inner: String = chars[inner_start..j.saturating_sub(1)].iter().collect();
            let subst: String = chars[i..j].iter().collect();
            current.push_str(&subst);
            segments.extend(split_shell_segments(&inner));
            i = j;
            continue;
        }

        // Process substitution <(...) and >(...) — similar to $(...)
        if (c == '<' || c == '>') && i + 1 < len && chars[i + 1] == '(' && !in_double_quote {
            let inner_start = i + 2;
            let mut depth = 1;
            let mut j = inner_start;
            while j < len && depth > 0 {
                match chars[j] {
                    '(' => depth += 1,
                    ')' => depth -= 1,
                    _ => {}
                }
                j += 1;
            }
            let inner: String = chars[inner_start..j.saturating_sub(1)].iter().collect();
            let subst: String = chars[i..j].iter().collect();
            current.push_str(&subst);
            segments.extend(split_shell_segments(&inner));
            i = j;
            continue;
        }

        // Backtick — process in both unquoted and double-quoted contexts
        if c == '`' {
            let inner_start = i + 1;
            let mut j = inner_start;
            let mut sq = false;
            let mut dq = false;
            while j < len {
                let ch = chars[j];
                if ch == '\'' && !dq {
                    sq = !sq;
                } else if ch == '"' && !sq {
                    if !is_escaped(&chars, j) {
                        dq = !dq;
                    }
                } else if ch == '`' && !sq && !dq {
                    break;
                }
                j += 1;
            }
            let inner: String = chars[inner_start..j].iter().collect();
            let end = if j < len { j + 1 } else { len };
            let subst: String = chars[i..end].iter().collect();
            current.push_str(&subst);
            segments.extend(split_shell_segments(&inner));
            i = end;
            continue;
        }

        // Outside quotes: handle shell operators
        if !in_double_quote {
            // && operator (check before single &)
            if c == '&' && i + 1 < len && chars[i + 1] == '&' {
                let trimmed = current.trim().to_string();
                if !trimmed.is_empty() {
                    segments.push(trimmed);
                }
                current.clear();
                i += 2;
                continue;
            }

            // || operator (check before single |)
            if c == '|' && i + 1 < len && chars[i + 1] == '|' {
                let trimmed = current.trim().to_string();
                if !trimmed.is_empty() {
                    segments.push(trimmed);
                }
                current.clear();
                i += 2;
                continue;
            }

            // Single & (background operator)
            if c == '&' {
                let trimmed = current.trim().to_string();
                if !trimmed.is_empty() {
                    segments.push(trimmed);
                }
                current.clear();
                i += 1;
                continue;
            }

            // | pipe
            if c == '|' {
                let trimmed = current.trim().to_string();
                if !trimmed.is_empty() {
                    segments.push(trimmed);
                }
                current.clear();
                i += 1;
                continue;
            }

            // ; semicolon
            if c == ';' {
                let trimmed = current.trim().to_string();
                if !trimmed.is_empty() {
                    segments.push(trimmed);
                }
                current.clear();
                i += 1;
                continue;
            }

            // \n newline
            if c == '\n' {
                let trimmed = current.trim().to_string();
                if !trimmed.is_empty() {
                    segments.push(trimmed);
                }
                current.clear();
                i += 1;
                continue;
            }
        }

        current.push(c);
        i += 1;
    }

    let trimmed = current.trim().to_string();
    if !trimmed.is_empty() {
        segments.push(trimmed);
    }

    segments
}

/// Normalize a command segment for pattern matching.
/// Strips leading subshell/brace-group openers, shell keywords, and command prefixes.
fn normalize_segment(segment: &str) -> &str {
    let mut s = segment.trim();
    // Strip leading subshell/brace group openers
    s = s.trim_start_matches(|c: char| c == '(' || c == '{').trim();
    // Strip trailing subshell/brace group closers
    s = s.trim_end_matches(|c: char| c == ')' || c == '}').trim();
    // Strip leading shell keywords
    for keyword in ["then ", "do ", "else "] {
        if let Some(rest) = s.strip_prefix(keyword) {
            s = rest.trim();
            break;
        }
    }
    // Strip leading command prefixes (loop to handle chained prefixes like "env command git push")
    loop {
        let prev = s;
        for prefix in ["env ", "command ", "exec "] {
            if let Some(rest) = s.strip_prefix(prefix) {
                s = rest.trim();
                break;
            }
        }
        if std::ptr::eq(s, prev) {
            break;
        }
    }
    s
}

/// Check a single segment against blocked patterns, recursing into shell wrappers.
fn check_segment(segment: &str, reasons: &mut Vec<&'static str>, depth: u8) {
    if depth > 5 {
        return;
    }
    let normalized = normalize_segment(segment);

    for pattern in BLOCKED_PATTERNS {
        if starts_with_command(normalized, pattern.prefix) && !reasons.contains(&pattern.reason) {
            reasons.push(pattern.reason);
        }
    }

    if let Some(reason) = check_npm_cdk(normalized) {
        if !reasons.contains(&reason) {
            reasons.push(reason);
        }
    }

    // Recurse into shell wrappers (sh -c, bash -c, zsh -c)
    if let Some(inner) = extract_shell_c_arg(normalized) {
        let inner_segments = split_shell_segments(&inner);
        for inner_seg in &inner_segments {
            check_segment(inner_seg, reasons, depth + 1);
        }
    }
}

/// Check if a Bash command contains any blocked patterns.
/// Returns a combined reason string if blocked, None if allowed.
pub fn check_blocked_command(command: &str) -> Option<String> {
    let command = strip_line_continuations(command);
    let segments = split_shell_segments(&command);
    let mut reasons: Vec<&str> = Vec::new();

    for segment in &segments {
        check_segment(segment, &mut reasons, 0);
    }

    if reasons.is_empty() {
        None
    } else {
        Some(reasons.join("\n"))
    }
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
            return Some(s[1..1 + end].to_string());
        }
    } else if s.starts_with('\'') {
        if let Some(end) = s[1..].find('\'') {
            return Some(s[1..1 + end].to_string());
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

    // === is_escaped ===

    #[test]
    fn test_is_escaped() {
        let chars: Vec<char> = r#"hello\"world"#.chars().collect();
        // The " at position 6 is preceded by one backslash -> escaped
        assert!(is_escaped(&chars, 6));

        let chars2: Vec<char> = r#"hello\\"world"#.chars().collect();
        // The " at position 7 is preceded by two backslashes -> not escaped
        assert!(!is_escaped(&chars2, 7));
    }

    // === starts_with_command ===

    #[test]
    fn test_starts_with_command() {
        assert!(starts_with_command("git push", "git push"));
        assert!(starts_with_command("git push origin main", "git push"));
        assert!(!starts_with_command("git pushed", "git push"));
        assert!(!starts_with_command("git restore-mtime .", "git restore"));
        assert!(starts_with_command("git restore --staged file.txt", "git restore"));
    }

    // === Simple blocked commands ===

    #[test]
    fn test_simple_blocked() {
        assert!(check_blocked_command("git push").is_some());
        assert!(check_blocked_command("git push origin main").is_some());
        assert!(check_blocked_command("git reset --hard HEAD~1").is_some());
        assert!(check_blocked_command("git checkout main").is_some());
        assert!(check_blocked_command("git stash").is_some());
        assert!(check_blocked_command("git restore .").is_some());
        assert!(check_blocked_command("gh pr close 123").is_some());
        assert!(check_blocked_command("terraform apply").is_some());
        assert!(check_blocked_command("terraform destroy").is_some());
    }

    // === Safe commands ===

    #[test]
    fn test_safe_commands() {
        assert!(check_blocked_command("git status").is_none());
        assert!(check_blocked_command("git log --oneline").is_none());
        assert!(check_blocked_command("git diff").is_none());
        assert!(check_blocked_command("git add file.rs").is_none());
        assert!(check_blocked_command("ls -la").is_none());
        assert!(check_blocked_command("echo hello").is_none());
        assert!(check_blocked_command("gh pr list").is_none());
        assert!(check_blocked_command("terraform plan").is_none());
        assert!(check_blocked_command("npm run test").is_none());
        assert!(check_blocked_command("npm run build").is_none());
    }

    // === Bypass with shell operators ===

    #[test]
    fn test_bypass_and() {
        let r = check_blocked_command("echo foo && git push").unwrap();
        assert!(r.contains("git push"));
    }

    #[test]
    fn test_bypass_semicolon() {
        let r = check_blocked_command("echo foo; git push").unwrap();
        assert!(r.contains("git push"));
    }

    #[test]
    fn test_bypass_or() {
        let r = check_blocked_command("false || git push").unwrap();
        assert!(r.contains("git push"));
    }

    #[test]
    fn test_bypass_pipe() {
        assert!(check_blocked_command("echo foo | git push").is_some());
    }

    #[test]
    fn test_bypass_background() {
        assert!(check_blocked_command("echo hello & git push").is_some());
    }

    // === Bypass with command substitution ===

    #[test]
    fn test_bypass_command_substitution() {
        let r = check_blocked_command("echo $(git push)").unwrap();
        assert!(r.contains("git push"));
    }

    #[test]
    fn test_bypass_backticks() {
        let r = check_blocked_command("echo `git push`").unwrap();
        assert!(r.contains("git push"));
    }

    // === Bypass with process substitution ===

    #[test]
    fn test_bypass_process_substitution() {
        assert!(check_blocked_command("cat <(git push)").is_some());
        assert!(check_blocked_command("diff <(git push) /dev/null").is_some());
    }

    // === Bypass with subshell / brace group ===

    #[test]
    fn test_bypass_subshell() {
        assert!(check_blocked_command("(git push)").is_some());
    }

    #[test]
    fn test_bypass_brace_group() {
        assert!(check_blocked_command("{ git push; }").is_some());
    }

    // === Bypass with newline / line continuation ===

    #[test]
    fn test_bypass_newline() {
        assert!(check_blocked_command("echo foo\ngit push").is_some());
    }

    #[test]
    fn test_bypass_line_continuation() {
        assert!(check_blocked_command("git \\\npush origin main").is_some());
    }

    // === Bypass with shell keywords ===

    #[test]
    fn test_bypass_shell_keywords() {
        assert!(check_blocked_command("if true; then git push; fi").is_some());
        assert!(check_blocked_command("for x in a; do git push; done").is_some());
    }

    // === Bypass with command prefixes ===

    #[test]
    fn test_bypass_env_prefix() {
        assert!(check_blocked_command("env git push").is_some());
        assert!(check_blocked_command("command git push").is_some());
        assert!(check_blocked_command("exec git push").is_some());
    }

    // === Bypass with shell wrappers (sh -c, bash -c) ===

    #[test]
    fn test_bypass_sh_c() {
        assert!(check_blocked_command("sh -c \"git push\"").is_some());
        assert!(check_blocked_command("bash -c 'git push'").is_some());
        assert!(check_blocked_command("zsh -c \"git push\"").is_some());
        assert!(check_blocked_command("/bin/sh -c \"git push\"").is_some());
        assert!(check_blocked_command("bash -c \"echo foo && git push\"").is_some());
    }

    // === Escaped backslash before quote ===

    #[test]
    fn test_escaped_backslash() {
        // echo "\\" is echo of a single backslash; the && is a real operator
        assert!(check_blocked_command(r#"echo "\\" && git push"#).is_some());
    }

    // === $() in double quotes (bash expands), in single quotes (bash doesn't) ===

    #[test]
    fn test_command_substitution_in_double_quotes() {
        assert!(check_blocked_command("echo \"$(git push)\"").is_some());
    }

    #[test]
    fn test_command_substitution_in_single_quotes() {
        assert!(check_blocked_command("echo '$(git push)'").is_none());
    }

    // === Quoted strings should NOT be blocked ===

    #[test]
    fn test_quoted_not_blocked() {
        assert!(check_blocked_command("echo \"git push\"").is_none());
        assert!(check_blocked_command("echo 'git push'").is_none());
    }

    // === Multiple blocked commands ===

    #[test]
    fn test_multiple_blocked() {
        let r = check_blocked_command("git push && terraform apply").unwrap();
        assert!(r.contains("git push"));
        assert!(r.contains("terraform apply"));
    }

    // === npm cdk patterns ===

    #[test]
    fn test_npm_cdk() {
        assert!(check_blocked_command("npm run cdk deploy").is_some());
        assert!(check_blocked_command("npm run -- cdk deploy").is_some());
        assert!(check_blocked_command("npm run cdk destroy").is_some());
        assert!(check_blocked_command("npm run -- cdk destroy").is_some());
    }

    // === No duplicate reasons ===

    #[test]
    fn test_no_duplicate_reasons() {
        let r = check_blocked_command("git push; git push origin main").unwrap();
        let count = r.matches("git push is blocked").count();
        assert_eq!(count, 1);
    }

    // === Word boundary ===

    #[test]
    fn test_word_boundary() {
        assert!(check_blocked_command("git restore-mtime .").is_none());
        assert!(check_blocked_command("git restore --staged file.txt").is_some());
    }

    // === split_shell_segments ===

    #[test]
    fn test_split_basic() {
        assert_eq!(split_shell_segments("echo foo && git push").len(), 2);
        assert_eq!(split_shell_segments("a; b; c").len(), 3);
    }

    #[test]
    fn test_split_preserves_quoted_operators() {
        assert_eq!(split_shell_segments("echo \"foo && bar\"").len(), 1);
        assert_eq!(split_shell_segments("echo 'foo; bar'").len(), 1);
    }

    #[test]
    fn test_split_command_substitution_extracts_inner() {
        let segs = split_shell_segments("echo $(git push)");
        assert!(segs.len() >= 2);
    }

    #[test]
    fn test_split_background_operator() {
        let segs = split_shell_segments("echo hello & git push");
        assert_eq!(segs.len(), 2);
    }

    // === strip_line_continuations ===

    #[test]
    fn test_strip_line_continuations() {
        assert_eq!(strip_line_continuations("git \\\npush"), "git push");
        assert_eq!(strip_line_continuations("echo hello"), "echo hello");
    }

    // === normalize_segment ===

    #[test]
    fn test_normalize_segment() {
        assert_eq!(normalize_segment("  (git push)  "), "git push");
        assert_eq!(normalize_segment("{ git push }"), "git push");
        assert_eq!(normalize_segment("then git push"), "git push");
        assert_eq!(normalize_segment("do git push"), "git push");
        assert_eq!(normalize_segment("env git push"), "git push");
        assert_eq!(normalize_segment("command git push"), "git push");
        assert_eq!(normalize_segment("env command git push"), "git push");
    }

    // === extract_target_file_from_bash ===


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
        assert_eq!(
            extract_filename("\"test.txt\""),
            Some("test.txt".to_string())
        );
        assert_eq!(
            extract_filename("'test.txt'"),
            Some("test.txt".to_string())
        );
        assert_eq!(
            extract_filename("test.txt | grep foo"),
            Some("test.txt".to_string())
        );
        assert_eq!(
            extract_filename("test.txt && echo done"),
            Some("test.txt".to_string())
        );
    }
}
