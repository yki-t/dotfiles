use crate::models::HookInput;
use std::process::Command;

pub fn handle_notification(input: &HookInput) {
    let notification_type = match input.notification_type.as_deref() {
        Some(t) => t,
        None => return,
    };

    if notification_type != "idle_prompt" {
        return;
    }

    let body = match input.cwd.as_deref() {
        Some(cwd) => format!("Claude: {cwd}"),
        None => "Claude: input waiting".to_string(),
    };

    let _ = Command::new("notify-send")
        .arg("--app-name=Claude Code")
        .arg("--icon=dialog-information")
        .arg("Claude Code")
        .arg(&body)
        .status();
}
