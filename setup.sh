#!/bin/bash
set -e

DNSMASQ_BIN="/usr/local/sbin/dnsmasq"
CONFIG_DIR="/usr/local/etc"
LOG_DIR="/usr/local/var/log"
SCRIPT_PATH="/usr/local/bin/update_blocklists.sh"
PLIST_PATH="/Library/LaunchDaemons/net.dnsmasq.plist"
PLIST_LABEL="net.dnsmasq"

echo "--- blackholedns Setup Script ---"

if [ ! -f "$DNSMASQ_BIN" ]; then
    echo "ERROR: dnsmasq binary not found at $DNSMASQ_BIN."
    echo "Please install dnsmasq first (e.g., via MacPorts) and ensure the binary is at this path."
    exit 1
fi

echo "Cleaning up any previous net.dnsmasq service definition..."
sudo launchctl unload "$PLIST_PATH" 2>/dev/null || true
sudo rm -f "$PLIST_PATH"

echo "Setting up configuration directories and files..."
sudo mkdir -p "$CONFIG_DIR/dnsmasq.d/blocklists"
sudo mkdir -p "$LOG_DIR"
sudo cp dnsmasq.conf "$CONFIG_DIR/"
sudo cp blocklist_sources.txt "$CONFIG_DIR/"

# Copy update script and make executable
sudo cp update_blocklists.sh "$SCRIPT_PATH"
sudo chmod +x "$SCRIPT_PATH"

echo "Creating Launch Daemon file: $PLIST_PATH"
cat << EOF | sudo tee "$PLIST_PATH" > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$PLIST_LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$DNSMASQ_BIN</string>
        <string>--keep-in-foreground</string>
        <string>-C</string>
        <string>$CONFIG_DIR/dnsmasq.conf</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ThrottleInterval</key>
    <integer>5</integer>
    <key>UserName</key>
    <string>root</string>
    <key>StandardErrorPath</key>
    <string>$LOG_DIR/dnsmasq.err.log</string>
    <key>StandardOutPath</key>
    <string>$LOG_DIR/dnsmasq.log</string>
</dict>
</plist>
EOF

sudo chown root:wheel "$PLIST_PATH"
sudo chmod 644 "$PLIST_PATH"

echo "Running initial blocklist download (this may take a minute)..."
sudo "$SCRIPT_PATH"

echo "Starting dnsmasq..."
sudo launchctl load "$PLIST_PATH"

echo ""
echo "--- Installation Complete ---"
echo "1. Verify the service is running: sudo launchctl list | grep $PLIST_LABEL"
echo "2. Configure your Mac's DNS to use 127.0.0.1 (System Settings -> Network -> Details -> DNS)."
