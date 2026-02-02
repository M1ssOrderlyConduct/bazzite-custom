# Bazzite Custom

Custom Bazzite Deck GNOME image with pre-configured apps.

## Included

| App | Type | Description |
|-----|------|-------------|
| Claude Code | npm | AI coding assistant |
| Proton Pass | Flatpak | Password manager |
| Tailscale | System | VPN mesh network |
| Moonlight | Flatpak | Game streaming client |
| Sunshine | Flatpak | Game streaming host |
| ClamAV/ClamTK | System+Flatpak | Antivirus |
| BTOP | System | System monitor |
| TrueNAS NFS | fstab | Auto-mount at /mnt/truenas/prowlarr |

## Setup

### 1. Generate signing key
```bash
COSIGN_PASSWORD="" cosign generate-key-pair
```

### 2. Add secret to GitHub
- Go to Settings → Secrets → Actions
- Add `SIGNING_SECRET` with contents of `cosign.key`
- Commit `cosign.pub` to the repo

### 3. Enable GitHub Actions
- Go to Actions tab and enable workflows

### 4. Switch to your image
After the first build succeeds:
```bash
sudo bootc switch ghcr.io/YOUR_USERNAME/bazzite-custom:stable
```

## Post-Install
Run `bazzite-custom-setup` after first boot to install Flatpaks.

## Local Build
```bash
podman build -t bazzite-custom .
```
