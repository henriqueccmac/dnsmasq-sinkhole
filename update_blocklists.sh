#!/bin/bash

# Configuration paths
BLOCKLIST_DIR="/usr/local/etc/dnsmasq.d/blocklists"
SOURCES_FILE="/usr/local/etc/blocklist_sources.txt"
LOG_FILE="/usr/local/var/log/dnsmasq_update.log"

# Commands using full paths
CURL="/usr/bin/curl"
RM="/bin/rm"
ECHO="/bin/echo"
WC="/usr/bin/wc"
LAUNCHCTL="/bin/launchctl"

# 1. Clean and Log
$RM -f "$BLOCKLIST_DIR"/*
$ECHO "Starting update at $($ECHO "$(date)")" >> "$LOG_FILE"

# 2. Download Function
download_list() {
    URL="$1"
    FILENAME=$($ECHO "$URL" | sed -E 's/.*\/(.*)/\1/' | sed 's/[^a-zA-Z0-9._-]/_/g') 

    $ECHO "Downloading: $URL" >> "$LOG_FILE"
    if ! $CURL -sSL "$URL" > "$BLOCKLIST_DIR/$FILENAME"; then
        $ECHO "ERROR: Failed to download $URL" >> "$LOG_FILE"
        return 1
    fi
    $ECHO "Downloaded $($WC -l < "$BLOCKLIST_DIR/$FILENAME") entries." >> "$LOG_FILE"
}

# 3. Process Sources
while IFS= read -r URL; do
    if [[ -z "$URL" || "$URL" =~ ^# ]]; then
        continue
    fi
    download_list "$URL"
done < "$SOURCES_FILE"

# 4. Restart Dnsmasq using launchctl (requires root/sudo for system daemon)
$ECHO "Update complete. Restarting dnsmasq via launchctl..." >> "$LOG_FILE"
# Stopping and immediately loading the service forces a restart
sudo $LAUNCHCTL stop net.dnsmasq
sudo $LAUNCHCTL start net.dnsmasq
