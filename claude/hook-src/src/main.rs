use clap::Parser;
use serde_json;
use std::io::{self, Read};

mod cli;
mod handlers;
mod models;
mod services;
mod utils;

use cli::Cli;
use handlers::{
    notification::handle_notification, post::handle_post_tool_use, pre::handle_pre_tool_use,
    swarm_guard::handle_swarm_guard,
    worktree::{handle_worktree_create, handle_worktree_remove},
};
use models::{HookInput, HookOutput};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();

    // Read JSON from stdin
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)?;

    // Parse JSON
    let input: HookInput = serde_json::from_str(&buffer)?;

    // Handle commands with non-HookOutput protocols (early return)
    match &cli.command {
        cli::Commands::WorktreeCreate => {
            match handle_worktree_create(&input) {
                Ok(path) => {
                    print!("{}", path);
                    return Ok(());
                }
                Err(e) => {
                    eprintln!("{}", e);
                    std::process::exit(1);
                }
            }
        }
        cli::Commands::WorktreeRemove => {
            if let Err(e) = handle_worktree_remove(&input) {
                eprintln!("{}", e);
                std::process::exit(1);
            }
            return Ok(());
        }
        cli::Commands::Notification => {
            handle_notification(&input);
            return Ok(());
        }
        _ => {}
    }

    // Handle based on command
    let result = match &cli.command {
        cli::Commands::Pre => handle_pre_tool_use(&input),
        cli::Commands::Post => handle_post_tool_use(&input),
        cli::Commands::SwarmGuard => handle_swarm_guard(&input),
        _ => unreachable!(),
    };

    // Process result and output HookOutput for PreToolUse
    match (&cli.command, result) {
        (cli::Commands::Pre | cli::Commands::SwarmGuard, Err(e)) => {
            // Block with reason
            let output = HookOutput {
                decision: "block".to_string(),
                reason: Some(e.to_string()),
            };
            println!("{}", serde_json::to_string(&output)?);
        }
        (cli::Commands::Pre | cli::Commands::SwarmGuard, Ok(())) => {
            // Allow - no output needed
        }
        (cli::Commands::Post, _) => {
            // PostToolUse doesn't return decision
        }
        _ => unreachable!(),
    }

    Ok(())
}