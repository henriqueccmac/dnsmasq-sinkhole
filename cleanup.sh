#!/bin/bash
set -e

CONFIG_DIR="/usr/local/etc"
LOG_DIR="/usr/local/var/log"
SCRIPT_PATH="/usr/local/bin/update_blocklists.sh"
PLIST_PATH="/Library/LaunchDaemons/net.dnsmasq.plist"
PLIST_LABEL="net.dnsmasq"
CRON_JOB="/usr/local/bin/update_blocklists.sh"

echo "--- Cleanup Script ---"

echo "1. Stopping and unloading the net.dnsmasq service..."
sudo launchctl unload "$PLIST_PATH" 2>/dev/null || true
sudo rm -f "$PLIST_PATH"

echo "2. IMPORTANT: Manually remove the cron job if you set one up:"
echo "   Run 'sudo crontab -e' and delete the line referencing $CRON_JOB."

echo "3. Removing configuration files and logs..."

sudo rm -f "$CONFIG_DIR/dnsmasq.conf"
sudo rm -f "$CONFIG_DIR/blocklist_sources.txt"
sudo rm -rf "$CONFIG_DIR/dnsmasq.d"
sudo rm -f "$SCRIPT_PATH"
sudo rm -f "$LOG_DIR/dnsmasq.log"
sudo rm -f "$LOG_DIR/dnsmasq.err.log"
sudo rm -f "$LOG_DIR/dnsmasq_update.log"

echo "4. Reset your Mac's DNS settings."
echo "Cleanup complete. You may now uninstall the dnsmasq binary if you wish."
