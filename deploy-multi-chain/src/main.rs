use std::collections::HashMap;
use std::env;
use std::fs;
use std::path::Path;
use std::process::Command;
use toml::Value;

fn main() {
    // Process command-line arguments
    let args: Vec<String> = env::args().collect();
    let mut iter = args.iter().skip(1);

    // Variables to store flags and provided chains
    let mut broadcast_deployment = "".to_string();
    let mut script_name = "DeployProtocol.s.sol".to_string();
    let mut gas_price = "".to_string();
    let mut on_all_chains = false;
    let mut provided_chains = Vec::new();

    // Parse all arguments
    while let Some(arg) = iter.next() {
        match arg.as_str() {
            "--all" => on_all_chains = true,
            "--deterministic" => script_name = "DeployDeterministicProtocol.s.sol".to_string(),
            "--broadcast" => broadcast_deployment = " --broadcast --verify".to_string(),
            "--gas-price" => {
                let value = iter.next().expect("gas price value").to_string();
                gas_price = format!(" --gas-price {}", value);
            }
            _ => {
                if !arg.starts_with("--") && !on_all_chains {
                    provided_chains.push(arg.to_string());
                } else {
                    println!("Unknown flag: {}", arg);
                }
            }
        }
    }

    let mut chains = Vec::new();
    chains = get_all_chains();

    if on_all_chains {
        provided_chains = chains;
    } else {
        provided_chains.retain(|chain| {
            if chains.contains(chain) {
                true // Keep the element in the vector
            } else {
                println!("Chain {} is not configured in the TOML file", chain);
                false // Remove the element from the vector
            }
        });
    }

    // Default to "sepolia" if no chains are specified and --all is not used
    if provided_chains.is_empty() && !on_all_chains {
        provided_chains.push("sepolia".to_string());
    }

    // Output the list of unique chains
    let chains_string = provided_chains.clone().join(", ");
    println!("Deploying to the chains: {}", chains_string);

    let command = format!(
        "FOUNDRY_PROFILE=optimized forge script ../script/protocol/{}{}{}",
        script_name, broadcast_deployment, gas_price
    );

    for chain in provided_chains {
        let deployment_command = format!("{} --rpc-url {}", command, chain);

        println!("Running the deployment command: {}", deployment_command);

        // Split the command into parts
        let parts: Vec<&str> = deployment_command.split_whitespace().collect();

        // Set the environment variable
        let env_var = parts[0];
        let env_var_parts: Vec<&str> = env_var.split('=').collect();
        std::env::set_var(env_var_parts[0], env_var_parts[1]);

        // Define the command and arguments
        let mut cmd = Command::new(parts[1]);
        cmd.args(&parts[2..]);

        // Capture the command output
        let output = cmd.output().expect("Failed to run command");

        // Check if the command executed successfully
        if output.status.success() {
            let output_str = String::from_utf8_lossy(&output.stdout);
            println!("Command output: {}", output_str);
        }
    }
}

// Function that reads the TOML chain configurations and extracts them
fn get_all_chains() -> Vec<String> {
    // Define the path to the TOML file
    let toml_path = Path::new("../foundry.toml");

    // Read and parse the TOML file content
    let toml_content = match fs::read_to_string(toml_path) {
        Ok(content) => content,
        Err(_) => {
            eprintln!("Failed to read the TOML file");
            return Vec::new();
        }
    };

    let toml_values: Value = match toml::from_str(&toml_content) {
        Ok(value) => value,
        Err(_) => {
            eprintln!("Failed to parse TOML content");
            return Vec::new();
        }
    };

    // Extract chains from the TOML data
    let sections = ["rpc_endpoints", "etherscan"];
    let mut chains = Vec::new();

    for section in &sections {
        if let Some(table) = toml_values.get(section).and_then(|v| v.as_table()) {
            chains.extend(table.keys().filter(|&key| key != "localhost").cloned());
        }
    }

    chains.into_iter().collect()
}
