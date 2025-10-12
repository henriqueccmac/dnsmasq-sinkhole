# BlackHole - a dnsmasq pi-hole based DNS Filter config

## Features

System-wide ad and tracker blocking on macOS by using **dnsmasq** to filter DNS requests before they are resolved. This setup runs as a persistent, low-level system service.

* **System-level Filtering:** Blocks domains across all applications.
* **Persistent Service:** Runs automatically at boot using a macOS Launch Daemon.
* **Curated Blocklists:** Uses optimized hosts files for effective coverage from [Pi-hole-Optimized-Blocklists](https://github.com/zachlagden/Pi-hole-Optimized-Blocklists/tree/main).

## Usage

### Prerequisites

macOS.

This guide assumes you have **dnsmasq** at **`/usr/local/sbin/dnsmasq`**.
It is recommended to do a manual install. Installing via homebrew can lead to permission hell when starting with `brew services`.

To install, download the latest [dnsmasq](https://thekelleys.org.uk/dnsmasq/), unzip it and `make install`.

--- 

## Config Installation

Run the setup script with root privileges:

```bash
sudo ./setup.sh
```

After installation, you must manually change your network settings to use the local DNS filter.

You can do this on the terminal:
```bash
# WARNING: this will overwrite your DNS configurations
sudo networksetup -setdnsservers Wi-Fi 127.0.0.1
```

### Maintenance and Automation

To fetch the latest blocklists, run the update script:

```bash
sudo /usr/local/bin/update_blocklists.sh
```

#### Automation Tip (Cron Job)

To automate the update, use crontab. Open the editor with `sudo crontab -e` and add the following line (e.g., for a weekly update every Sunday at 3:00 AM):

```Code snippet
0 3 * * 0 /usr/local/bin/update_blocklists.sh > /dev/null 2>&1
```

## Uninstall

To remove all configuration files, run the cleanup script:

```Bash
sudo ./cleanup.sh
```

## VPN Configuration and DNS Leaks
Since dnsmasq binds to the local address `127.0.0.1`, DNS queries are resolved before entering any VPN tunnel. This results in a **DNS leak** relative to the VPN's privacy features.

To maintain full VPN privacy, you must disable the service before connecting and re-enable it after disconnecting.
