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

# --- Enable Services ---
echo "Enabling services..."

# Tailscale (already included in Bazzite, just ensure enabled)
systemctl enable tailscaled.service

# ClamAV freshclam auto-update
systemctl enable clamav-freshclam.service

# --- TrueNAS NFS Mount ---
echo "Configuring TrueNAS NFS mount..."
# /mnt may be a symlink in atomic images, create mount point in /var instead
mkdir -p /var/mnt/truenas/prowlarr
# Use systemd mount unit instead of fstab for better atomic compatibility
cat > /etc/systemd/system/var-mnt-truenas-prowlarr.mount << 'MOUNT'
[Unit]
Description=TrueNAS Prowlarr Share
After=network-online.target
Wants=network-online.target

[Mount]
What=10.0.50.95:/mnt/oZFSmandias/downloads/prowlarr
Where=/var/mnt/truenas/prowlarr
Type=nfs
Options=rw,soft,noatime

[Install]
WantedBy=multi-user.target
MOUNT

cat > /etc/systemd/system/var-mnt-truenas-prowlarr.automount << 'AUTOMOUNT'
[Unit]
Description=Automount TrueNAS Prowlarr Share

[Automount]
Where=/var/mnt/truenas/prowlarr
TimeoutIdleSec=300

[Install]
WantedBy=multi-user.target
AUTOMOUNT

systemctl enable var-mnt-truenas-prowlarr.automount

# --- Flatpak Pre-configuration ---
# Flatpaks are installed at first boot via system config
mkdir -p /usr/share/ublue-os/bazzite/flatpak
cat > /usr/share/ublue-os/bazzite/flatpak/custom-install << 'FLATPAKS'
com.protonmail.protonpass
com.moonlight_stream.Moonlight
dev.lizardbyte.app.Sunshine
com.github.davem.ClamTk
FLATPAKS

# --- Post-install script for user setup ---
# Note: Claude Code installed via Homebrew post-boot (npm global doesn't work in atomic builds)
cat > /usr/bin/bazzite-custom-setup << 'SETUP'
#!/bin/bash
# Run once after first boot to complete setup

echo "=== Bazzite Custom Setup ==="

# Install Flatpaks
echo "Installing Flatpaks..."
flatpak install -y flathub com.protonmail.protonpass
flatpak install -y flathub com.moonlight_stream.Moonlight
flatpak install -y flathub dev.lizardbyte.app.Sunshine
flatpak install -y flathub com.github.davem.ClamTk

# Install Claude Code via Homebrew
echo "Installing Claude Code..."
if command -v brew &> /dev/null; then
    brew install node
    npm install -g @anthropic-ai/claude-code
else
    echo "Install Homebrew first: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
fi

# Update ClamAV definitions
echo "Updating ClamAV definitions..."
sudo freshclam || true

echo ""
echo "=== Setup Complete ==="
echo "Run 'sudo tailscale up' to connect Tailscale"
echo "TrueNAS mount: /var/mnt/truenas/prowlarr"
echo "Run 'claude' to start Claude Code"
SETUP
chmod +x /usr/bin/bazzite-custom-setup

echo "=== Build Complete ==="
