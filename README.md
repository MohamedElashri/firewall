# Firewall - UFW CLI Manager

Firewall - UFW CLI Manager is a user-friendly command-line interface for managing the `ufw` firewall on Debian and Ubuntu systems. It provides a simplified syntax and an intuitive set of commands to control `ufw`, making it easier to configure and manage firewall rules.

## Features

- Enable, disable, and restart the firewall
- Display the current status of the firewall
- List current firewall rules with optional filtering by application profile, port, IP, or protocol
- Allow or deny incoming and outgoing traffic on specific ports or port ranges
- Allow or deny traffic from specific IP addresses or subnets
- Manage predefined application profiles
- Enable or disable firewall logging
- Reset the firewall to its default settings
- Backup and restore firewall configurations

## Installation

There are two methods to install the UFW CLI Manager:

### Method 1: Manual Installation

1. Download the `firewall.sh` script from the repository.

2. Make the script executable by running the following command:
   ```
   chmod +x firewall.sh
   ```

3. Move the script to a directory in your system's `PATH`, such as `/usr/local/bin/`, to make it accessible from anywhere:
   ```
   sudo mv firewall.sh /usr/local/bin/firewall
   ```

4. You can now use the `firewall` command from the terminal to manage UFW.

### Method 2: Automated Installation

1. Download the `install_firewall.sh` script from the repository:
   ```
   wget https://github.com/MohamedElashri/firewall/raw/main/install_firewall.sh
   ```

2. Make the installation script executable:
   ```
   chmod +x install_firewall.sh
   ```

3. Run the installation script with sudo or as root:
   ```
   sudo ./install_firewall.sh
   ```

   The script will download the `firewall.sh` script, make it executable, and move it to the `/usr/local/bin/` directory.

4. After the installation is complete, you can use the `firewall` command from the terminal to manage UFW.

## Usage

The `ufw` CLI Manager provides a set of commands to manage the firewall. Here's a table of the available commands:

| Command                           | Description                                                   |
|-----------------------------------|---------------------------------------------------------------|
| `firewall start`                  | Enable the firewall                                          |
| `firewall stop`                   | Disable the firewall                                         |
| `firewall restart`                | Restart the firewall                                         |
| `firewall status`                 | Display the current status of the firewall                   |
| `firewall list [app,port,ip,protocol]` | Display the current firewall rules (optionally filtered) |
| `firewall allow port <port> [tcp,udp]` | Allow incoming traffic on a specific port or port range  |
| `firewall deny port <port> [tcp,udp]`  | Deny incoming traffic on a specific port or port range   |
| `firewall allow out <port> [tcp,udp]` | Allow outgoing traffic on a specific port or port range  |
| `firewall deny out <port> [tcp,udp]`  | Deny outgoing traffic on a specific port or port range   |
| `firewall allow ip <ip>`          | Allow traffic from a specific IP address or subnet           |
| `firewall deny ip <ip>`           | Deny traffic from a specific IP address or subnet            |
| `firewall app list`               | List all available application profiles                      |
| `firewall app info <profile>`     | Display information about a specific application profile     |
| `firewall app allow <profile>`    | Allow traffic based on a predefined application profile      |
| `firewall app deny <profile>`     | Deny traffic based on a predefined application profile       |
| `firewall logging on`             | Enable firewall logging                                      |
| `firewall logging off`            | Disable firewall logging                                     |
| `firewall reset`                  | Reset the firewall to its default settings                   |
| `firewall backup [filename]`      | Backup the current firewall configuration to a file          |
| `firewall restore <filename>`     | Restore the firewall configuration from a backup file        |

## Examples

- Enable the firewall:
  ```
  firewall start
  ```

- Allow incoming SSH traffic on port 22:
  ```
  firewall allow port 22
  ```

- Deny outgoing traffic on port 80 for the TCP protocol:
  ```
  firewall deny out 80 tcp
  ```

- Allow traffic from a specific IP address:
  ```
  firewall allow ip 192.168.0.10
  ```

- List all available application profiles:
  ```
  firewall app list
  ```

- Enable firewall logging:
  ```
  firewall logging on
  ```

- Backup the current firewall configuration to a file:
  ```
  firewall backup firewall_config.bak
  ```

## Uninstallation

To uninstall the `ufw` CLI Manager, simply remove the `firewall` script from the directory where it was installed. For example:
```
sudo rm /usr/local/bin/firewall
```

## Security Considerations

- Firewall - `ufw` CLI Manager script includes input validation and error handling to ensure the correctness of the provided arguments.
- Firewall changes are logged to the `/var/log/firewall.log` file for auditing purposes. Make sure to regularly monitor this file for any suspicious activities.
- The script requires sudo or root privileges to execute `ufw` commands. Ensure that only authorized users have access to the script and the necessary privileges.

## Disclaimer

While Firewall - UFW CLI Manager aims to simplify firewall management, it is essential to understand the implications of the firewall rules being applied. Incorrectly configured firewall rules may result in unintended consequences, such as blocking legitimate traffic or exposing your system to security risks. Use this script responsibly and review the firewall rules carefully before applying them.

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgements

The UFW CLI Manager script is built on top of the `ufw` firewall package and utilizes its underlying functionality. I would like to acknowledge the developers and maintainers of `ufw` for their excellent work.

## Contributing

Contributions to the UFW CLI Manager project are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request on the project's GitHub repository.
