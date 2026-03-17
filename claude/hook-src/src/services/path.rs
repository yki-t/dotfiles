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

pub fn resolve_path(file_path: &str, cwd: Option<&str>) -> String {
    if file_path.starts_with('/') {
        file_path.to_string()
    } else if let Some(cwd) = cwd {
        format!("{}/{}", cwd, file_path)
    } else {
        // Relative path without cwd - is_under_tmp will reject it (fail-closed)
        file_path.to_string()
    }
}

pub fn check_subagent_file_path(file_path: &str, cwd: Option<&str>, tool_name: &str) -> Result<()> {
    let resolved = resolve_path(file_path, cwd);
    if !is_under_tmp(&resolved) {
        return Err(anyhow::anyhow!(
            "Sub-agent cannot use {tool_name} on paths outside /tmp/. Target: {resolved}"
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
}
