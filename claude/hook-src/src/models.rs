use serde::{Deserialize, Serialize};
use serde_json::Value;

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
pub struct HookInput {
    pub session_id: String,
    pub transcript_path: String,
    pub hook_event_name: String,
    pub tool_name: String,
    pub tool_input: ToolInput,
    #[serde(default)]
    pub tool_response: Option<serde_json::Value>,
}

#[derive(Debug, Deserialize)]
pub struct ToolInput {
    #[serde(default)]
    pub file_path: Option<String>,
    #[serde(default)]
    pub command: Option<String>,
    #[serde(flatten)]
    pub other: serde_json::Map<String, Value>,
}

#[derive(Debug, Serialize)]
pub struct HookOutput {
    pub decision: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub reason: Option<String>,
}