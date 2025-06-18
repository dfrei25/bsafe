#!/usr/bin/env bash
#
# meant to be included by bsafe,
# containing all application profile configuration

#### Profile categories

# drop as much as possible. The whole script is bottom-up designed
restrict_everything() {
  bwrap_args+=(
    # drop all capabilities by default. This should be bwrap default, however
    --cap-drop ALL
    # unshare all namespaces by default
    --unshare-user
    --unshare-ipc
    --unshare-pid
    --unshare-net
    --unshare-uts
    --unshare-cgroup
    # disconnect from terminal, so sandbox can't inject input into the terminal
    --new-session
    # Ensures child process (COMMAND) dies when bwrap's parent dies (SIGKILL)
    --die-with-parent
    --clearenv
  )
}

# essential/general stuff to run most applications
allow_basics() {
  bwrap_args+=(
    --proc /proc
    --dev-bind /dev /dev # might wanna be more restrictive here
    --tmpfs /tmp
    --tmpfs /run
    --symlink usr/lib /lib
    --symlink usr/lib64 /lib64
    --symlink usr/bin /bin
    --symlink usr/bin /sbin
  )
  ro_files+=(
    /etc
    /sys
    /usr
    /opt
  )
  rw_files+=("$HOME/Downloads") # always available
  env_vars+=(
    "PATH"
    "HOME"
    "PWD"
    "JAVAC"
    "JAVA_HOME"
    "JDK_HOME"
    "LANG"
    "LC_COLLATE"
    "LC_MESSAGES"
    "LOGNAME"
    "USER"
    "XDG_CONFIG_DIRS"
    "XDG_CONFIG_HOME"
    "XDG_DATA_DIRS"
    "XDG_RUNTIME_DIR"
    "XDG_SESSION_CLASS"
  )
}

allow_sound() {
  rw_files+=(
    "$HOME/.config/pulse"
    "$XDG_RUNTIME_DIR/pipewire-0"
    "$XDG_RUNTIME_DIR/pipewire-0.lock"
    "$XDG_RUNTIME_DIR/pulse"
  )
}

allow_net() {
  bwrap_args+=(--share-net)
  ro_files+=(
    /run/systemd/resolve
    /run/NetworkManager/resolv.conf
  )
}

allow_gui() {
  env_vars+=(
    "DISPLAY"
    "GDK_BACKEND"
    "GSETTINGS_BACKEND"
    "GTK2_RC_FILES"
    "GTK_THEME"
    "GTK_USE_PORTAL"
    "LIBVA_DRIVERS_PATH"
    "LIBVA_DRIVER_NAME"
    "QT_QPA_PLATFORM"
    "QT_STYLE_OVERRIDE"
    "SDL_VIDEODRIVER"
    "WAYLAND_DISPLAY"
    "XCURSOR_SIZE"
    "XCURSOR_THEME"
    "XDG_CURRENT_DESKTOP"
    "XDG_MENU_PREFIX"
    "XDG_SEAT"
    "XDG_SESSION_DESKTOP"
    "XDG_SESSION_ID"
    "XDG_SESSION_TYPE"
    "XDG_VTNR"
    "MESA_VK_DEVICE_SELECT"
  )
  ro_files+=(
    "$HOME/.Xauthority"
    "$XDG_CONFIG_HOME/mimeapps.list" # doesn't really belong here
  )
  rw_files+=(
    "$XDG_RUNTIME_DIR/wayland-1"
    "$XDG_RUNTIME_DIR/wayland-1.lock"
    "/tmp/.X11-unix/X0"
  )
}

allow_dbus() {
  env_vars+=(
    "DBUS_SESSION_BUS_ADDRESS"
    "I3SOCK"
    "SWAYSOCK"
  )

  if [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    rw_files+=("${DBUS_SESSION_BUS_ADDRESS//unix:path=/}")
  fi

  local atspi_dir="$XDG_RUNTIME_DIR/at-spi"
  [[ ! -d "$atspi_dir" ]] && mkdir -p "$atspi_dir" && rw_files+=("$atspi_dir")
  [[ -e /run/dbus/system_bus_socket ]] && rw_files+=(/run/dbus/system_bus_socket)
  [[ -d "$XDG_RUNTIME_DIR/dbus-1" ]] && rw_files+=("$XDG_RUNTIME_DIR/dbus-1")
  [[ -e "$XDG_RUNTIME_DIR/bus" ]] && rw_files+=("$XDG_RUNTIME_DIR/bus")
}

allow_term() {
  ro_files+=("$HOME/.zshrc")
  env_vars+=(
    "COLORTERM"
    "EDITOR"
    "INFOPATH"
    "LESS"
    "LESSOPEN"
    "LEX"
    "MANPAGER"
    "MANPATH"
    "MOTD_SHOWN"
    "NNN_FIFO"
    "NNN_PLUG"
    "OLDPWD"
    "PAGER"
    "PATH"
    "PWD"
    "SHELL"
    "SHLVL"
    "TERM"
    "TERMINFO_DIRS"
  )
}

allow_rwhome() {
  rw_files+=(
    "$HOME"
  )
}

# Use the same namespace as the real user
allow_userns() {
  remove_items_from_array bwrap_args "--unshare-user"
}

allow_games() {
  local env_vars+=(
    "DXVK_ASYNC"
    "STEAM_RUNTIME"
    "STEAM_RUNTIME_PREFER_HOST_LIBRARIES"
    "WINEDEBUG"
    "PROTON_ENABLE_WAYLAND"
  )
  rw_files+=(
    "$HOME/.local/Terraria"
    "$HOME/.factorio"
  )
}

# profile sync daemon
allow_psd() {
  rw_files+=("$XDG_RUNTIME_DIR/psd")
}

#### seccomp profiles, wip.
# Currently using a long but commented blacklist (see syscall_blacklist.inc.sh)
# using all jirejail entities but removed ones plus a few other critical ones
# run tools/compare_firejail_blacklist.sh for details
syscalls_ipc=(msgctl msgget msgrcv msgsnd shmctl shmdt shmget shmat semctl semget semop semtimedop)

#### permission settings per app
load_application_profile() {

  # when no application profile got manually selected, default to command
  if [[ -z $application_profile ]]; then
    application_profile="${executable}"
  fi

  case $application_profile in
    steam)
      allow_gui
      allow_sound
      allow_dbus
      allow_net
      allow_games
      seccomp_whitelist+=(pivot_root mount umount2 get_mempolicy process_vm_readv kcmp sched_setattr i386.kcmp)
      ;;
    zsh)
      allow_gui
      allow_sound
      allow_net
      allow_term
      ro_files+=("$HOME/.zshrc")
      bwrap_args+=(--setenv PS1 "\(bwrap\)\$PS1") # sandbox indicator
      ;;
    discord)
      allow_gui
      allow_sound
      allow_dbus
      allow_net
      allow_sound
      rw_files+=("$HOME/.config/discord")
      ro_files+=(/opt/discord)
      seccomp_whitelist+=(unshare chroot)
      ;;
    google-chrome-stable)
      allow_gui
      allow_sound
      allow_net
      seccomp_whitelist+=(unshare chroot)
      ;;
    firefox)
      allow_gui
      allow_sound
      allow_dbus
      allow_net
      allow_psd # profile-sync-daemon
      env_vars+=(
        "MOZ_DRM_DEVICE"
        "MOZ_GMP_PATH"
      )
      firejail_profile="firefox-esr"
      seccomp_whitelist+=(unshare chroot kcmp)
      ;;
    hexchat)
      allow_gui
      allow_sound
      allow_dbus
      allow_net
      ;;
    untrusted)
      seccomp_blacklist+=("${syscalls_ipc[@]}" socket mprotect pkey_mprotect)
      bwrap_args+=(--disable-userns) # sets user.max_user_namespaces=1
      ;;
    gui)
      allow_gui
      ;;
    *)
      return 1
      ;;
  esac

  # Remove the whitelisted syscalls from blacklist
  remove_items_from_array seccomp_blacklist "${seccomp_whitelist[@]}"
}
