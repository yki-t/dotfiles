use clap::Parser;
use serde_json;
use std::io::{self, Read};

mod cli;
mod handlers;
mod models;
mod utils;

use cli::Cli;
use handlers::{post::handle_post_tool_use, pre::handle_pre_tool_use};
use models::{HookInput, HookOutput};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();

    // Read JSON from stdin
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)?;

    // Parse JSON
    let input: HookInput = serde_json::from_str(&buffer)?;

    // Handle based on command
    let result = match &cli.command {
        cli::Commands::Pre => handle_pre_tool_use(&input),
        cli::Commands::Post => handle_post_tool_use(&input),
    };

    // Process result and output HookOutput for PreToolUse
    match (&cli.command, result) {
        (cli::Commands::Pre, Err(e)) => {
            // Block with reason
            let output = HookOutput {
                decision: "block".to_string(),
                reason: Some(e.to_string()),
            };
            println!("{}", serde_json::to_string(&output)?);
        }
        (cli::Commands::Pre, Ok(())) => {
            // Allow - no output needed
        }
        (cli::Commands::Post, _) => {
            // PostToolUse doesn't return decision
        }
    }

    Ok(())
}