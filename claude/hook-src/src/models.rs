use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize)]
pub struct HookInput {
    #[serde(rename = "session_id")]
    pub _session_id: String,
    #[serde(rename = "transcript_path")]
    pub _transcript_path: String,
    #[serde(rename = "hook_event_name")]
    pub _hook_event_name: String,
    pub tool_name: String,
    pub tool_input: ToolInput,
    #[serde(default, rename = "tool_response")]
    pub _tool_response: Option<serde_json::Value>,
}

#[derive(Debug, Deserialize)]
pub struct ToolInput {
    #[serde(default)]
    pub file_path: Option<String>,
    #[serde(default)]
    pub command: Option<String>,
}

#[derive(Debug, Serialize)]
pub struct HookOutput {
    pub decision: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub reason: Option<String>,
}