#!/bin/bash
set -ouex pipefail

echo "=== Building Custom Bazzite Image ==="

# --- System Packages (rpm-ostree/dnf5) ---
echo "Installing system packages..."

# ClamAV antivirus
dnf5 install -y clamav clamav-update clamd

# BTOP system monitor
dnf5 install -y btop

# NFS utilities for TrueNAS mounts
dnf5 install -y nfs-utils

# Node.js for Claude Code
dnf5 install -y nodejs npm

# --- Enable Services ---
echo "Enabling services..."

# Tailscale (already included in Bazzite, just ensure enabled)
systemctl enable tailscaled.service

# ClamAV freshclam auto-update
systemctl enable clamav-freshclam.service

# --- Flatpak Pre-configuration ---
# Flatpaks are installed at first boot via system config
# Create flatpak list for first-boot installation
mkdir -p /usr/share/ublue-os/bazzite/flatpak
cat > /usr/share/ublue-os/bazzite/flatpak/custom-install << 'FLATPAKS'
com.protonmail.protonpass
com.moonlight_stream.Moonlight
dev.lizardbyte.app.Sunshine
com.github.davem.ClamTk
FLATPAKS

# --- Claude Code ---
# Install globally via npm (will be available after first boot)
npm install -g @anthropic-ai/claude-code || echo "Claude Code will need manual install post-boot"

# --- Post-install script for user setup ---
mkdir -p /usr/local/bin
cat > /usr/local/bin/bazzite-custom-setup << 'SETUP'
#!/bin/bash
# Run once after first boot to complete setup

echo "Installing Flatpaks..."
flatpak install -y flathub com.protonmail.protonpass
flatpak install -y flathub com.moonlight_stream.Moonlight
flatpak install -y flathub dev.lizardbyte.app.Sunshine
flatpak install -y flathub com.github.davem.ClamTk

echo "Updating ClamAV definitions..."
sudo freshclam

echo "Setup complete!"
echo "Run 'sudo tailscale up' to connect Tailscale"
echo "TrueNAS mount: /mnt/truenas/prowlarr"
SETUP
chmod +x /usr/local/bin/bazzite-custom-setup

echo "=== Build Complete ==="
