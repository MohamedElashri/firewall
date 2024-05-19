#!/bin/bash

# Check if the script is running on a Debian-based system
if ! grep -qi "debian" /etc/os-release && ! grep -qi "ubuntu" /etc/os-release; then
    echo "This script is designed to run on Debian or Ubuntu systems only."
    exit 1
fi

# Check if ufw is installed
if ! command -v ufw &> /dev/null; then
    echo "ufw (Uncomplicated Firewall) is not installed. Please install it and try again."
    exit 1
fi

# Function to display the usage message
usage() {
    echo "Usage: firewall [command] [options]"
    echo ""
    echo "Commands:"
    echo "  start                     Enable the firewall"
    echo "  stop                      Disable the firewall"
    echo "  restart                   Restart the firewall"
    echo "  status                    Display the current status of the firewall"
    echo "  list [app|port|ip|protocol]  Display the current firewall rules (optionally filtered)"
    echo "  allow port <port> [tcp|udp]  Allow incoming traffic on a specific port or port range"
    echo "  deny port <port> [tcp|udp]   Deny incoming traffic on a specific port or port range"
    echo "  allow out <port> [tcp|udp]   Allow outgoing traffic on a specific port or port range"
    echo "  deny out <port> [tcp|udp]    Deny outgoing traffic on a specific port or port range"
    echo "  allow ip <ip|any>         Allow traffic from a specific IP address, subnet, or 'any' for all IPs"
    echo "  deny ip <ip|any>          Deny traffic from a specific IP address, subnet, or 'any' for all IPs"
    echo "  delete <rule_number/s>      Delete a specific firewall rule by its number"
    echo "  app list                  List all available application profiles"
    echo "  app info <profile>        Display information about a specific application profile"
    echo "  app allow <profile>       Allow traffic based on a predefined application profile"
    echo "  app deny <profile>        Deny traffic based on a predefined application profile"
    echo "  logging on                Enable firewall logging"
    echo "  logging off               Disable firewall logging"
    echo "  reset                     Reset the firewall to its default settings"
    echo "  backup [filename]         Backup the current firewall configuration to a file"
    echo "  restore <filename>        Restore the firewall configuration from a backup file"
    echo "  nuke                      Reset all firewall rules to default and re-enable the firewall"
}

# Function to check if a rule already exists
rule_exists() {
    local rule="$1"
    sudo ufw status | grep -q "$rule"
}

# Function to validate port number
validate_port() {
    local port="$1"
    if [ "$port" == "any" ]; then
        return 0  # Skip the numeric check if 'any' is specified
    elif ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo "Invalid port number: $port. Please provide a valid port between 1 and 65535 or 'any'."
        return 1
    fi
}

# Function to validate IP address (IPv4 and IPv6) or "any"
validate_ip() {
    local ip="$1"
    if [ "$ip" != "any" ]; then
        if ! echo "$ip" | grep -q -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
            if ! echo "$ip" | grep -q -E '^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$'; then
                echo "Invalid IP address: $ip. Please provide a valid IPv4 or IPv6 address or 'any'."
                return 1
            fi
        fi
    fi
}

# Function to log firewall changes
log_changes() {
    local action="$1"
    local rule="$2"
    local timestamp
    local user

    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    user=$(whoami)

    echo "$timestamp - $user - $action - $rule" >> /var/log/firewall.log
}
# Log file path
LOG_FILE="/var/log/firewall.log"

# Check if the log file exists, create it if necessary
if [ ! -f "$LOG_FILE" ]; then
    sudo touch "$LOG_FILE"
    sudo chown root:adm "$LOG_FILE"
    sudo chmod 640 "$LOG_FILE"
fi

# Parse command line arguments
case "$1" in
    start)
        sudo ufw enable -y
        ;;
    stop)
        sudo ufw disable
        ;;
    restart)
        sudo ufw reload
        ;;
    status)
        sudo ufw status
        ;;
    list)
        case "$2" in
            app)
                sudo ufw app list
                ;;
            port)
                sudo ufw status numbered
                ;;
            ip)
                sudo ufw status numbered
                ;;
            protocol)
                sudo ufw status numbered
                ;;
            *)
                sudo ufw status numbered
                ;;
        esac
        ;;
    allow)
        case "$2" in
            port)
                if [ "$3" == "any" ]; then
                    rule="allow from any to any"
                else
                    if ! validate_port "$3"; then
                        exit 1
                    fi
                    rule="allow $3 ${4:-tcp}"
                fi
                if rule_exists "$rule"; then
                    echo "Rule '$rule' already exists. Use 'firewall list' to check existing rules."
                else
                    sudo ufw "$rule"
                    log_changes "allow" "$rule"
                fi
                ;;
            out)
                if [ "$3" == "any" ]; then
                    rule="allow out on any"
                else
                    if ! validate_port "$3"; then
                        exit 1
                    fi
                    rule="allow out on $3 ${4:-tcp}"
                fi
                if rule_exists "$rule"; then
                    echo "Rule '$rule' already exists. Use 'firewall list' to check existing rules."
                else
                    sudo ufw "$rule"
                    log_changes "allow out" "$rule"
                fi
                ;;
            *)
                echo "Invalid allow command. Use 'firewall allow port|out|ip'."
                ;;
        esac
        ;;

    deny)
        case "$2" in
            port)
                if [ "$3" == "any" ]; then
                    rule="deny from any to any"
                else
                    if ! validate_port "$3"; then
                        exit 1
                    fi
                    rule="deny $3 ${4:-tcp}"
                fi
                if rule_exists "$rule"; then
                    echo "Rule '$rule' already exists. Use 'firewall list' to check existing rules."
                else
                    sudo ufw "$rule"
                    log_changes "deny" "$rule"
                fi
                ;;
            out)
                if [ "$3" == "any" ]; then
                    rule="deny out on any"
                else
                    if ! validate_port "$3"; then
                        exit 1
                    fi
                    rule="deny out on $3 ${4:-tcp}"
                fi
                if rule_exists "$rule"; then
                    echo "Rule '$rule' already exists. Use 'firewall list' to check existing rules."
                else
                    sudo ufw "$rule"
                    log_changes "deny out" "$rule"
                fi
                ;;
            *)
                echo "Invalid deny command. Use 'firewall deny port|out|ip'."
                ;;
        esac
        ;;
    app)
        case "$2" in
            list)
                sudo ufw app list
                ;;
            info)
                sudo ufw app info "$3"
                ;;
            allow)
                sudo ufw allow "$3"
                log_changes "allow app" "$3"
                ;;
            deny)
                sudo ufw deny "$3"
                log_changes "deny app" "$3"
                ;;
            *)
                echo "Invalid app command. Use 'firewall app list|info|allow|deny'."
                ;;
        esac
        ;;
    delete)
        if [ -z "$2" ]; then
            echo "Please provide the rule number(s) to delete."
        else
            cleaned_input=$(echo "$2" | tr -d '[]' | tr ',' '\n' | sort -nr)
            for rule_number in $cleaned_input; do
                if ! [[ "$rule_number" =~ ^[0-9]+$ ]]; then
                    echo "Invalid rule number: $rule_number. Please provide valid rule numbers."
                    continue
                fi
                sudo ufw --force delete "$rule_number"
                log_changes "delete" "Rule $rule_number"
                echo "Rule $rule_number has been deleted."
            done
        fi
        ;;
        logging)
        case "$2" in
            on)
                sudo ufw logging on
                ;;
            off)
                sudo ufw logging off
                ;;
            *)
                echo "Invalid logging command. Use 'firewall logging on|off'."
                ;;
        esac
        ;;
    reset)
        sudo ufw reset
        log_changes "reset" ""
        ;;
    backup)
        if [ -z "$2" ]; then
            sudo ufw status numbered > firewall_backup.txt
            echo "Firewall configuration backed up to firewall_backup.txt"
        else
            sudo ufw status numbered > "$2"
            echo "Firewall configuration backed up to $2"
        fi
        ;;
    restore)
        if [ -z "$2" ]; then
            echo "Please provide the backup file to restore."
        else
            sudo ufw reset
            sudo ufw disable
            sudo cp "$2" /etc/ufw/user.rules
            sudo chown root:root /etc/ufw/user.rules
            sudo chmod 0640 /etc/ufw/user.rules
            sudo ufw enable
            echo "Firewall configuration restored from $2"
            log_changes "restore" "$2"
        fi
        ;;
    nuke)
        echo "Resetting all firewall rules to default..."
        sudo ufw disable
        echo "Resetting to factory defaults..."
        yes | sudo ufw reset  # Automatically confirm the reset
        echo "Re-enabling firewall with default settings..."
        yes | sudo ufw enable  # Automatically confirm enabling
        log_changes "nuke" "All rules reset to default, firewall re-enabled with no rules."
        echo "Firewall rules have been nuked and reset to default state."
        ;;

    *)
        usage
        ;;
esac