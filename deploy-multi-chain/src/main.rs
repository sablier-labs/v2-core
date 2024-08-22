use serde_json::Value;
use std::env;
use std::fs;
use std::fs::OpenOptions;
use std::io::Write;
use std::path::Path;
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};
use toml::Value as TomlValue;

fn main() {
    // Process command-line arguments
    let args: Vec<String> = env::args().collect();
    let mut iter = args.iter().skip(1);

    // Variables to store flags and provided chains
    let mut broadcast_deployment = "".to_string();
    let mut cp_broadcasted_file = false;
    let mut gas_price = "".to_string();
    let mut is_deterministic = false;
    let mut script_name = "DeployProtocol.s.sol".to_string();
    let mut on_all_chains = false;
    let mut provided_chains = Vec::new();

    // Parse all arguments
    while let Some(arg) = iter.next() {
        match arg.as_str() {
            "--all" => on_all_chains = true,
            "--cp-bf" => cp_broadcasted_file = true,
            "--deterministic" => {
                script_name = "DeployDeterministicProtocol.s.sol".to_string();
                is_deterministic = true;
            }
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

    let chains = get_all_chains();

    if on_all_chains {
        provided_chains = chains;
    } else {
        // Filter out chains that are not configured in the TOML file
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

    let deployment_path = get_deployment_path(is_deterministic, false);

    // Check if the deployment file exists
    if Path::new(&deployment_path).exists() {
        // Move the existing file to a new path with timestamp
        _ = fs::rename(
            &deployment_path,
            get_deployment_path(is_deterministic, true),
        );
    } else {
        // Create the parent directory
        _ = fs::create_dir_all(Path::new(&deployment_path).parent().unwrap());
    }

    // Append the type of deployment at the start of the deployment file
    append_type_of_deployment(&deployment_path, !broadcast_deployment.is_empty());

    for chain in provided_chains {
        let env_var = "FOUNDRY_PROFILE=optimized";
        let command = "forge";
        let script_arg = format!("../script/protocol/{}", script_name);

        let command_args = vec![
            "script",
            &script_arg,
            "--rpc-url",
            &chain,
            &broadcast_deployment,
            &gas_price,
        ];

        println!(
            "Running the deployment command: {} {} {}",
            env_var,
            command,
            command_args.join(" ")
        );

        // Set the environment variable
        let env_var_parts: Vec<&str> = env_var.split('=').collect();
        env::set_var(env_var_parts[0], env_var_parts[1]);

        // Create the CLI and capture the command output
        let output = Command::new(command)
            .args(command_args)
            .output()
            .expect("Failed to run command");

        // Process command output
        let output_str = String::from_utf8_lossy(&output.stdout);
        if output.status.success() {
            println!("Command output: {}", output_str);
        } else {
            eprintln!(
                "Command failed with error: {}",
                String::from_utf8_lossy(&output.stderr)
            );
        }

        // Move broadcast file if needed
        if cp_broadcasted_file {
            move_broadcast_file(
                &script_name,
                &chain,
                &output_str,
                !broadcast_deployment.is_empty(),
            );
        }
    }

    // Run Prettier to format the deployment files
    _ = Command::new("bun")
        .args(["prettier", "--write", "../deployments/**/*.md"])
        .status()
        .expect("Failed to run Prettier");
}

fn append_type_of_deployment(deployment_path: &str, is_broadcast_deployment: bool) {
    let message = match is_broadcast_deployment {
        true => " # This deployment is broadcasted\n\n",
        false => " # This deployment is a simulation\n\n",
    };

    OpenOptions::new()
        .append(true)
        .create(true)
        .open(deployment_path)
        .and_then(|mut file| file.write_all(message.as_bytes()))
        .expect("Failed to open or write to the file");
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

    let toml_values: TomlValue = match toml::from_str(&toml_content) {
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

fn get_deployment_path(is_deterministic: bool, with_timestamp: bool) -> String {
    let mut deployment_path = if is_deterministic {
        "../deployments/deterministic.md".to_string()
    } else {
        "../deployments/non_deterministic.md".to_string()
    };

    if with_timestamp {
        // Get the current Unix timestamp as a string
        let timestamp = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("Time went backwards")
            .as_secs()
            .to_string();

        // Insert the timestamp before the filename
        let filename_start = deployment_path.rfind('/').unwrap() + 1;
        deployment_path.insert_str(filename_start, &format!("{}_{}", timestamp, ""));
    }

    deployment_path
}

fn move_broadcast_file(
    script_name: &str,
    chain: &str,
    output: &str,
    is_broadcast_deployment: bool,
) {
    // Find the chain_id in the `output`
    let chain_id = output
        .split(&format!("broadcast/{}/", script_name))
        .nth(1)
        .and_then(|s| s.split('/').next())
        .unwrap_or("");

    let broadcast_file_path = if is_broadcast_deployment {
        format!("../broadcast/{}/{}/run-latest.json", script_name, chain_id)
    } else {
        format!(
            "../broadcast/{}/{}/dry-run/run-latest.json",
            script_name, chain_id
        )
    };

    let version = serde_json::from_str::<Value>(&fs::read_to_string("../package.json").unwrap())
        .unwrap()["version"]
        .as_str()
        .unwrap()
        .to_string();

    // Up to be changed, see this: https://github.com/sablier-labs/v2-deployments/issues/10
    let dest_path = format!(
        "../../v2-deployments/protocol/v{}/broadcasts/{}.json",
        version, chain
    );

    // Create the parent directory if it doesn't exist
    if let Some(parent) = Path::new(&dest_path).parent() {
        if !parent.exists() {
            fs::create_dir_all(parent).expect("Failed to create directories");
        }
    }

    // Move and rename the file
    fs::rename(&broadcast_file_path, &dest_path)
        .expect("Failed to move and rename run-latest.json to v2-deployments");
}
