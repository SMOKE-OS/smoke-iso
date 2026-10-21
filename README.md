# 💿 smoke-iso

Official [`archiso`](https://wiki.archlinux.org/title/archiso) build profile, automation recipes, and configuration for generating **SMOKE OS** live installation media.

[![Arch Linux](https://img.shields.io/badge/Base-Arch%20Linux-1793D1?style=flat&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Compositor](https://img.shields.io/badge/Compositor-Hyprland-00AAFF?style=flat&logo=wayland&logoColor=white)](https://hyprland.org/)
[![Status](https://img.shields.io/badge/Status-Early%20Alpha-yellow?style=flat)](https://github.com/SMOKE-OS)
[![License](https://img.shields.io/badge/License-GPLv3-blue?style=flat)](LICENSE)

---

## 📋 Prerequisites

To build the ISO locally on an Arch Linux system:

```bash
sudo pacman -S --needed archiso qemu-system-x86_64 edk2-ovmf
```

---

## 🛠️ Building the ISO

### Option A: Using the Automated CI/CD Pipeline (Recommended)
This repository includes a GitHub Actions workflow (`.github/workflows/build-iso.yml`) that builds the ISO in a clean, privileged Arch Linux container, signs/hashes it, and publishes a new GitHub Release.

- **Trigger on Git Tag**: Push any tag matching `v*` (e.g. `git tag v0.1BETA && git push origin v0.1BETA`).
- **Manual Trigger**: Run from the **Actions** tab in GitHub (`workflow_dispatch`) with custom version and timestamp options.
- **Naming Format**:
  ```text
  Smoke_os_<time stamp>_v<0.x>BETA.iso
  ```
  *(Example: `Smoke_os_20261021_0650_v0.1BETA.iso`)*

### Option B: Local Docker Build
If Docker is installed on your machine:
```bash
./build.sh 0.1
```

### Option C: Native Arch Linux Build
```bash
# 1. Clone repository
git clone https://github.com/SMOKE-OS/smoke-iso.git
cd smoke-iso

# 2. Build the ISO (requires root)
sudo mkarchiso -v -w /tmp/archiso-work -o ./out .
```

The output `.iso` file will be placed in the `./out/` directory.

---

## 🚀 Testing in QEMU

Test the generated ISO immediately in a virtual machine without needing a USB drive:

```bash
run_archiso -i ./out/smoke-os-*.iso
```

---

## 📁 Repository Structure

```
smoke-iso/
├── profiledef.sh          # ISO metadata, bootloader configuration, and file permissions
├── packages.x86_64        # List of packages included in the x86_64 live environment
├── pacman.conf            # Pacman package manager configuration
└── airootfs/              # Overlay filesystem copied directly into the live root
    └── etc/
        ├── skel/          # Default user configuration files & dotfiles (Hyprland, Waybar)
        └── systemd/       # System services enabled on live boot
```

---

## 🤝 Contributing & Philosophy

- Keep it minimal, fast, and bloat-free.
- Avoid redundant background daemons or heavy background runtimes.
- Test changes in QEMU prior to submitting pull requests.
