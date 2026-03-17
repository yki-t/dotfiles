use std::fs::OpenOptions;
use std::io::Write;

const DEBUG_DIR: &str = "/tmp/claude-code-hook-debug";

pub fn log_debug(message: &str) {
    if std::env::var_os("CH_DEBUG").is_none() {
        return;
    }
    let _ = std::fs::create_dir_all(DEBUG_DIR);
    if let Ok(mut file) = OpenOptions::new()
        .create(true)
        .append(true)
        .open(format!("{}/{}.log", DEBUG_DIR, std::process::id()))
    {
        let _ = writeln!(file, "[{}] {}", chrono::Utc::now().to_rfc3339(), message);
    }
}
