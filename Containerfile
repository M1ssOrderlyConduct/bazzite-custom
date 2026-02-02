# Custom Bazzite Deck GNOME Image
# Based on: https://github.com/ublue-os/image-template

FROM scratch AS ctx
COPY build_files /

# Base: Bazzite Deck GNOME (Steam Deck experience with GNOME desktop)
FROM ghcr.io/ublue-os/bazzite-deck-gnome:stable

# Build customizations (packages, services, NFS mount, setup script)
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

# Verify image
RUN bootc container lint
