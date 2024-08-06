use std::collections::HashMap;
use std::env;
use std::fs;
use std::path::Path;
use std::process::{Command, Stdio};
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
    let mut provided_chains: Vec<String> = Vec::new();

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

    // Before deploying, create the deployments directory to store the deployment addresses.
    create_deployments_dir();

    let command = format!(
        "FOUNDRY_PROFILE=optimized forge script ../script/{}{}{}",
        script_name, broadcast_deployment, gas_price
    );

    for chain in provided_chains {
        let deployment_command =
            format!("{} {} --rpc-url {}", command, get_script_sig(&chain), chain);

        println!("Running the deployment command: {}", deployment_command);

        // Execute the deployment command
        let output = Command::new("sh")
            .arg("-c")
            .arg(&deployment_command)
            .stdin(Stdio::null())
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .output()
            .expect("Failed to execute command");

        // Capture and print output
        let stdout = String::from_utf8_lossy(&output.stdout);
        let stderr = String::from_utf8_lossy(&output.stderr);

        // Print the command output in real-time
        if !stdout.is_empty() {
            print!("{}", stdout);
        }
        if !stderr.is_empty() {
            eprint!("{}", stderr);
        }

        // Check for error in output
        if stderr.contains("Error") {
            eprintln!("Deployment failed for chain {}", chain);
            std::process::exit(1);
        }
        // Create a file for the chain
        let chain_file = format!("{}/{}.txt", deployments_dir, chain);
        let mut file = fs::File::create(&chain_file).expect("Failed to create file");

        // Extract and save contract addresses
        let batch_lockup_address = extract_address(&stdout, "batchLockup: contract");
        let lockup_dynamic_address = extract_address(&stdout, "lockupDynamic: contract");
        let lockup_linear_address = extract_address(&stdout, "lockupLinear: contract");
        let lockup_tranched_address = extract_address(&stdout, "lockupTranched: contract");
        let merkle_lockup_factory_address =
            extract_address(&stdout, "merkleLockupFactory: contract");
        let nft_descriptor_address = extract_address(&stdout, "nftDescriptor: contract");

        // Save to the chain file
        writeln!(file, "Core Contracts").expect("Failed to write to file");
        writeln!(file, "SablierLockupDynamic = {}", lockup_dynamic_address)
            .expect("Failed to write to file");
        writeln!(file, "SablierLockupLinear = {}", lockup_linear_address)
            .expect("Failed to write to file");
        writeln!(file, "SablierLockupTranched = {}", lockup_tranched_address)
            .expect("Failed to write to file");
        writeln!(file, "SablierNFTDescriptor = {}", nft_descriptor_address)
            .expect("Failed to write to file");
        writeln!(file, "Periphery Contracts").expect("Failed to write to file");
        writeln!(file, "SablierBatchLockup = {}", batch_lockup_address)
            .expect("Failed to write to file");
        writeln!(
            file,
            "SablierMerkleLockupFactory = {}",
            merkle_lockup_factory_address
        )
        .expect("Failed to write to file");
    }
}

fn create_deployments_dir() {
    let deployments = "../deployments";
    let path = Path::new(deployments);

    // Check if the directory exists
    if path.exists() {
        // Attempt to remove the directory if it exists
        if let Err(e) = fs::remove_dir_all(deployments) {
            eprintln!("Failed to remove directory '{}': {}", deployments, e);
            return; // Exit the function if removal fails
        }
    }

    // Attempt to create the directory
    if let Err(e) = fs::create_dir(deployments) {
        eprintln!("Failed to create directory '{}': {}", deployments, e);
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

// Function to get admin address based on the chain name
fn get_script_sig(chain: &str) -> String {
    let mut admins = HashMap::new();
    let sablier_deployer = "0xb1bEF51ebCA01EB12001a639bDBbFF6eEcA12B9F";

    admins.insert("arbitrum", "0xF34E41a6f6Ce5A45559B1D3Ee92E141a3De96376");
    admins.insert("avalanche", "0x4735517616373c5137dE8bcCDc887637B8ac85Ce");
    admins.insert("base", "0x83A6fA8c04420B3F9C7A4CF1c040b63Fbbc89B66");
    admins.insert("bnb", "0x6666cA940D2f4B65883b454b7Bc7EEB039f64fa3");
    admins.insert("gnosis", "0x72ACB57fa6a8fa768bE44Db453B1CDBa8B12A399");
    admins.insert("mainnet", "0x79Fb3e81aAc012c08501f41296CCC145a1E15844");
    admins.insert("optimism", "0x43c76FE8Aec91F63EbEfb4f5d2a4ba88ef880350");
    admins.insert("polygon", "0x40A518C5B9c1d3D6d62Ba789501CE4D526C9d9C6");
    admins.insert("scroll", "0x0F7Ad835235Ede685180A5c611111610813457a9");

    // The admin address for the chain, or the default deployer address in case of testnets
    // and no multisig on specific chain
    let admin = admins.get(chain).unwrap_or(&sablier_deployer).to_string();

    format!("--sig \"run(address)\" {}", admin)
}
