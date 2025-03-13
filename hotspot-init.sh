#!/bin/bash

WIFI_INTERFACE="wlan1"
AP_SSID="FotoBox"
AP_CHANNEL="6"
IP_ADDRESS="192.168.100.1"
IP_NETMASK="255.255.255.0"
DHCP_RANGE="192.168.100.10,192.168.100.100"
LOG_FILE="/var/log/wifi_setup.log"


if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root" 
   exit 1
fi

handle_error() {
    local exit_code=$1
    local error_message=$2
    
    echo "ERROR: $error_message" >&2
    echo "$(date): ERROR: $error_message" >> "$LOG_FILE"
     
    exit "$exit_code"
}


check_command() {
    if [ $? -ne 0 ]; then
        handle_error 1 "Command failed: $1"
    else
        echo "SUCCESS: $1"
    fi
}


command_exists() {
    command -v "$1" >/dev/null 2>&1
}


package_installed() {
    dpkg -l "$1" | grep -q ^ii
}


service_running() {
    systemctl is-active --quiet "$1"
}


for cmd in wget unzip dpkg apt-get systemctl ifconfig; do
    if ! command_exists "$cmd"; then
        handle_error 1 "Required command not found: $cmd"
    fi
done


/usr/sbin/usb_modeswitch -KQ -v a69c -p 5723
check_command "Switch USB device mode"


# Check if interface exists after mode switch
sleep 5 # Give time for interface to appear
if ! ifconfig "$WIFI_INTERFACE" &>/dev/null; then
    echo "WARNING: Interface $WIFI_INTERFACE not detected. Will attempt to continue anyway."
fi


if ! package_installed hostapd; then
    apt-get install -y hostapd
    check_command "Install hostapd"
fi

if [ -f /etc/hostapd/hostapd.conf ]; then
    cp /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.bak
    echo "Created backup of existing hostapd configuration"
fi


cat > /etc/hostapd/hostapd.conf << EOT
# hostapd configuration for $AP_SSID
interface=$WIFI_INTERFACE
ssid=$AP_SSID
hw_mode=g
channel=$AP_CHANNEL
ignore_broadcast_ssid=0
EOT

check_command "Create hostapd configuration"

if [ -f /etc/default/hostapd ]; then
    sed -i 's|^#\?DAEMON_CONF=.*|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' /etc/default/hostapd
    check_command "Update hostapd default configuration"
else
    echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' > /etc/default/hostapd
    check_command "Create hostapd default configuration"
fi


systemctl unmask hostapd
systemctl enable hostapd
systemctl restart hostapd
check_command "Enable and start hostapd service"

if ! package_installed dnsmasq; then
    apt-get install -y dnsmasq
    check_command "Install dnsmasq"
fi

if [ -f /etc/dnsmasq.conf ]; then
    cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
    echo "Created backup of existing dnsmasq configuration"
fi

cat > /etc/dnsmasq.conf << EOT
# dnsmasq configuration for WiFi access point
# Listen on specific interface only
interface=$WIFI_INTERFACE
bind-interfaces
# No DHCP on other interfaces
no-dhcp-interface=eth0,lo,wlan0

# DHCP settings
dhcp-range=$DHCP_RANGE
dhcp-option=3,$IP_ADDRESS  # Default gateway
dhcp-option=6,8.8.8.8,8.8.4.4  # DNS servers

# Logging options
log-queries
log-dhcp
EOT
check_command "Create dnsmasq configuration"

systemctl enable dnsmasq
systemctl restart dnsmasq
check_command "Enable and restart dnsmasq service"


if [ -f /etc/network/interfaces.d/wlan1 ]; then
    mv /etc/network/interfaces.d/wlan1 /etc/network/interfaces.d/wlan1.bak
fi

mkdir -p /etc/network/interfaces.d/

cat > /etc/network/interfaces.d/wlan1 << EOT
auto $WIFI_INTERFACE
iface $WIFI_INTERFACE inet static
    address $IP_ADDRESS
    netmask $IP_NETMASK
EOT

check_command "Create network interface configuration"

ifconfig "$WIFI_INTERFACE" "$IP_ADDRESS" netmask "$IP_NETMASK" up
check_command "Configure interface IP address"


for service in hostapd dnsmasq; do
    if ! service_running "$service"; then
        echo "WARNING: $service is not running. Attempting to start..."
        systemctl restart "$service"
        if ! service_running "$service"; then
            echo "ERROR: Failed to start $service. Check logs for details."
            echo "You can debug with: journalctl -u $service"
        else
            echo "SUCCESS: $service started successfully"
        fi
    else
        echo "SUCCESS: $service is running"
    fi
done

if ! grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p
    check_command "Enable IP forwarding"
fi
