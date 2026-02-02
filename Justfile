# Custom Bazzite Build Commands

IMAGE_NAME := "bazzite-custom"

# Build the container image locally
build:
    podman build -t {{IMAGE_NAME}} .

# Build and run in a VM (requires qemu)
build-vm: build
    podman run --rm -it --privileged {{IMAGE_NAME}}

# Clean up build cache
clean:
    podman system prune -f
    podman image prune -f
