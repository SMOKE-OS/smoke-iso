#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-0.1}"
CLEAN_VER=$(echo "$VERSION" | sed -E 's/^v//; s/BETA$//i')
TIMESTAMP=$(date -u +'%Y%m%d_%H%M')
TARGET_NAME="Smoke_os_${TIMESTAMP}_v${CLEAN_VER}.iso"

echo "==> Building SMOKE OS Live ISO: ${TARGET_NAME}"
mkdir -p out work

docker run --rm --privileged \
  -v "${PWD}:/workspace" \
  -w /workspace \
  archlinux:latest \
  bash -c "
    set -ex
    pacman-key --init && pacman-key --populate archlinux
    pacman -Syu --noconfirm archiso git
    mkarchiso -v -w /workspace/work -o /workspace/out /workspace
  "

cd out
ORIGINAL_ISO=$(ls smoke-os-*.iso 2>/dev/null | head -n 1 || ls *.iso 2>/dev/null | head -n 1)
mv "$ORIGINAL_ISO" "$TARGET_NAME"
sha256sum "$TARGET_NAME" > "${TARGET_NAME}.sha256"

echo "==> Successfully built: out/${TARGET_NAME}"
echo "==> Checksum: out/${TARGET_NAME}.sha256"
