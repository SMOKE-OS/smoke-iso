# [[ -f ~/.bashrc ]] && . ~/.bashrc

# Autostart Hyprland on TTY1 in live ISO session
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec Hyprland
fi
