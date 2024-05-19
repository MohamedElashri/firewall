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
    echo "  allow ip <ip>             Allow traffic from a specific IP address or subnet"
    echo "  deny ip <ip>              Deny traffic from a specific IP address or subnet"
    echo "  app list                  List all available application profiles"
    echo "  app info <profile>        Display information about a specific application profile"
    echo "  app allow <profile>       Allow traffic based on a predefined application profile"
    echo "  app deny <profile>        Deny traffic based on a predefined application profile"
    echo "  logging on                Enable firewall logging"
    echo "  logging off               Disable firewall logging"
    echo "  reset                     Reset the firewall to its default settings"
    echo "  backup [filename]         Backup the current firewall configuration to a file"
    echo "  restore <filename>        Restore the firewall configuration from a backup file"
}

# Function to check if a rule already exists
rule_exists() {
    local rule="$1"
    sudo ufw status | grep -q "$rule"
}

# Function to validate port number
validate_port() {
    local port="$1"
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo "Invalid port number: $port. Please provide a valid port between 1 and 65535."
        return 1
    fi
}

# Function to validate IP address (IPv4 and IPv6)
validate_ip() {
    local ip="$1"
    if ! echo "$ip" | grep -q -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
        if ! echo "$ip" | grep -q -E '^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$'; then
            echo "Invalid IP address: $ip. Please provide a valid IPv4 or IPv6 address."
            return 1
        fi
    fi
}

# Function to log firewall changes
log_changes() {
    local action="$1"
    local rule="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local user=$(whoami)
    echo "$timestamp - $user - $action - $rule" >> /var/log/firewall.log
}

# Parse command line arguments
case "$1" in
    start)
        sudo ufw enable
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
                if [ -z "$4" ]; then
                    rule="$3"
                else
                    rule="$3/$4"
                fi
                if ! validate_port "$3"; then
                    exit 1
                fi
                if rule_exists "$rule"; then
                    echo "Rule '$rule' already exists. Use 'firewall list' to check existing rules."
                else
                    sudo ufw allow "$rule"
                    log_changes "allow" "$rule"
                fi
                ;;
            out)
                if [ -z "$4" ]; then
                    rule="$3"
                else
                    rule="$3/$4"
                fi
                if ! validate_port "$3"; then
                    exit 1
                fi
                if rule_exists "out $rule"; then
                    echo "Rule 'out $rule' already exists. Use 'firewall list' to check existing rules."
                else
                    sudo ufw allow out "$rule"
                    log_changes "allow out" "$rule"
                fi
                ;;
            ip)
                if ! validate_ip "$3"; then
                    exit 1
                fi
                rule="from $3"
                if rule_exists "$rule"; then
                    echo "Rule '$rule' already exists. Use 'firewall list' to check existing rules."
                else
                    sudo ufw allow from "$3"
                    log_changes "allow" "$rule"
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
                if [ -z "$4" ]; then
                    rule="$3"
                else
                    rule="$3/$4"
                fi
                if ! validate_port "$3"; then
                    exit 1
                fi
                if rule_exists "$rule"; then
                    echo "Rule '$rule' already exists. Use 'firewall list' to check existing rules."
                else
                    sudo ufw deny "$rule"
                    log_changes "deny" "$rule"
                fi
                ;;
            out)
                if [ -z "$4" ]; then
                    rule="$3"
                else
                    rule="$3/$4"
                fi
                if ! validate_port "$3"; then
                    exit 1
                fi
                if rule_exists "out $rule"; then
                    echo "Rule 'out $rule' already exists. Use 'firewall list' to check existing rules."
                else
                    sudo ufw deny out "$rule"
                    log_changes "deny out" "$rule"
                fi
                ;;
            ip)
                if ! validate_ip "$3"; then
                    exit 1
                fi
                rule="from $3"
                if rule_exists "$rule"; then
                    echo "Rule '$rule' already exists. Use 'firewall list' to check existing rules."
                else
                    sudo ufw deny from "$3"
                    log_changes "deny" "$rule"
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
    *)
        usage
        ;;
esac
