# Custom Bazzite Deck GNOME Image
# Based on: https://github.com/ublue-os/image-template

FROM scratch AS ctx
COPY build_files /

# Base: Bazzite Deck GNOME (Steam Deck experience with GNOME desktop)
FROM ghcr.io/ublue-os/bazzite-deck-gnome:stable

# Build customizations
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

# Add NFS mount configuration
RUN mkdir -p /mnt/truenas/prowlarr && \
    echo "10.0.50.95:/mnt/oZFSmandias/downloads/prowlarr /mnt/truenas/prowlarr nfs x-systemd.automount,x-systemd.mount-timeout=10,rw,soft,noatime 0 0" >> /etc/fstab

# Verify image
RUN bootc container lint
