use anyhow::Result;
use std::path::{Component, PathBuf};

/// Normalize a path by resolving `.` and `..` components without filesystem access.
pub fn normalize_path(path: &str) -> PathBuf {
    let path = PathBuf::from(path);
    let mut components = Vec::new();
    for component in path.components() {
        match component {
            Component::ParentDir => {
                // Only pop if there's a normal component to pop
                if matches!(components.last(), Some(Component::Normal(_)) | Some(Component::RootDir)) {
                    if !matches!(components.last(), Some(Component::RootDir)) {
                        components.pop();
                    }
                } else {
                    components.push(component);
                }
            }
            Component::CurDir => {} // skip
            _ => components.push(component),
        }
    }
    if components.is_empty() {
        PathBuf::from(".")
    } else {
        components.iter().collect()
    }
}

/// Check if a normalized absolute path is under `/tmp/`.
pub fn is_under_tmp(path: &str) -> bool {
    let normalized = normalize_path(path);
    normalized.starts_with("/tmp")
}

/// Check if a normalized path contains `/.claude/worktrees/`.
///
/// Uses `contains` instead of `starts_with` (unlike `is_under_tmp`) because
/// the worktree path is `${PROJECT_ROOT}/.claude/worktrees/` and the project
/// root varies. `contains` intentionally allows any project's worktrees.
/// Path traversal is prevented by `normalize_path` resolving `..` before this check.
pub fn is_under_claude_worktree(path: &str) -> bool {
    let normalized = normalize_path(path);
    normalized.to_string_lossy().contains("/.claude/worktrees/")
}

pub fn resolve_path(file_path: &str, cwd: Option<&str>) -> String {
    if file_path.starts_with('/') {
        file_path.to_string()
    } else if let Some(cwd) = cwd {
        format!("{}/{}", cwd, file_path)
    } else {
        // Relative path without cwd - allowlist checks will reject it (fail-closed)
        file_path.to_string()
    }
}

pub fn ensure_path_in_sandbox(file_path: &str, cwd: Option<&str>, tool_name: &str) -> Result<()> {
    let resolved = resolve_path(file_path, cwd);
    if !is_under_tmp(&resolved) && !is_under_claude_worktree(&resolved) {
        return Err(anyhow::anyhow!(
            "Sub-agent cannot use {tool_name} on paths outside /tmp/ or .claude/worktrees/. Target: {resolved}"
        ));
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_normalize_path_absolute() {
        assert_eq!(normalize_path("/tmp/foo/bar"), PathBuf::from("/tmp/foo/bar"));
    }

    #[test]
    fn test_normalize_path_with_dotdot() {
        assert_eq!(normalize_path("/tmp/foo/../bar"), PathBuf::from("/tmp/bar"));
        assert_eq!(
            normalize_path("/tmp/../../home/user"),
            PathBuf::from("/home/user")
        );
    }

    #[test]
    fn test_normalize_path_with_dot() {
        assert_eq!(normalize_path("/tmp/./foo"), PathBuf::from("/tmp/foo"));
    }

    #[test]
    fn test_normalize_path_relative() {
        assert_eq!(normalize_path("foo/bar"), PathBuf::from("foo/bar"));
        assert_eq!(normalize_path("foo/../bar"), PathBuf::from("bar"));
    }

    #[test]
    fn test_normalize_path_root_dotdot() {
        // Can't go above root
        assert_eq!(normalize_path("/.."), PathBuf::from("/"));
        assert_eq!(normalize_path("/../tmp"), PathBuf::from("/tmp"));
    }

    #[test]
    fn test_is_under_tmp() {
        assert!(is_under_tmp("/tmp/foo"));
        assert!(is_under_tmp("/tmp/foo/bar"));
        assert!(!is_under_tmp("/home/user/file"));
        assert!(!is_under_tmp("/var/tmp/file"));
    }

    #[test]
    fn test_is_under_tmp_bypass_attempt() {
        assert!(!is_under_tmp("/tmp/../../home/user/file"));
        assert!(!is_under_tmp("/tmp/../home/file"));
        assert!(is_under_tmp("/tmp/foo/../bar"));
    }

    #[test]
    fn test_is_under_claude_worktree() {
        assert!(is_under_claude_worktree(
            "/home/user/project/.claude/worktrees/branch/src/main.rs"
        ));
        assert!(is_under_claude_worktree(
            "/home/user/project/.claude/worktrees/branch"
        ));
        assert!(!is_under_claude_worktree("/home/user/project/src/main.rs"));
    }

    #[test]
    fn test_is_under_claude_worktree_bypass_attempt() {
        assert!(!is_under_claude_worktree(
            "/home/user/.claude/worktrees/../../etc/passwd"
        ));
        assert!(!is_under_claude_worktree(
            "/home/user/project/.claude/worktrees/../../../etc/passwd"
        ));
    }
}
