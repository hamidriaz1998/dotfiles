# Dotfiles

Personal config files for fish, Hyprland, waybar, ghostty, Zed, Starship, touchegg, and GNOME, managed with [GNU Stow](https://www.gnu.org/software/stow/). No installer script — everything below is a plain command you run yourself, so you know exactly what's happening on your machine.

## Structure

Each top-level directory is a stow package. Running `stow <package>` from the repo root symlinks its contents into `$HOME`.

| Package    | Target                        | Notes |
|------------|-------------------------------|-------|
| `fish/`    | `~/.config/fish/`              | shell config + functions, uses [Fisher](https://github.com/jorgebucaran/fisher) for plugins |
| `zsh/`     | `~/.zshenv`, `~/.zshrc`        | alternative to fish — stow only one of the two |
| `ghostty/` | `~/.config/ghostty/`           | terminal config; cursor shaders are a git submodule |
| `hypr/`    | `~/.config/hypr/`               | Hyprland config — only relevant if you're running Hyprland |
| `waybar/`  | `~/.config/waybar/`             | status bar config |
| `omarchy/` | `~/.config/omarchy/`           | hooks, backgrounds, branding for an Omarchy install |
| `starship/`| `~/.config/starship.toml`      | prompt config (Catppuccin Mocha) |
| `touchegg/`| `~/.config/touchegg/`          | touchpad gesture config — only relevant if you have a touchpad |
| `zed/`     | `~/.config/zed/`                | Zed editor config |
| `gnome/`   | *(not stowed)*                  | raw `dconf`/extension data, restored manually — see below |

## Prerequisites

Install `stow` and `git` first:

```bash
# Arch
sudo pacman -Sy --noconfirm stow git

# Debian/Ubuntu
sudo apt update && sudo apt install -y stow git

# Fedora
sudo dnf install -y stow git
```

Optional tools used by some configs — install whichever you actually want:

```bash
# eza (modern ls, used by fish aliases)
sudo pacman -S eza          # Arch
sudo apt install eza        # Debian/Ubuntu
sudo dnf install eza        # Fedora

# Starship prompt
curl -sS https://starship.rs/install.sh | sh

# touchegg (only if you have a touchpad and want gestures)
sudo pacman -S touchegg     # Arch
sudo apt install touchegg   # Debian/Ubuntu
sudo dnf install touchegg   # Fedora
```

## Installation

1. Clone the repo and grab the ghostty shader submodule:

   ```bash
   git clone --recurse-submodules https://github.com/hamidriaz1999/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

   (If already cloned without `--recurse-submodules`: `git submodule update --init --recursive`.)

2. Stow the packages you want. Pick **one** shell:

   ```bash
   stow fish     # or: stow zsh
   ```

   Then the rest, as applicable to your machine:

   ```bash
   stow ghostty
   stow waybar
   stow starship
   stow zed
   stow omarchy    # if running Omarchy
   stow hypr       # if running Hyprland
   stow touchegg   # if you have a touchpad
   ```

   Stow will refuse to overwrite a file that already exists and isn't a symlink it manages — move any pre-existing config (e.g. `~/.config/fish`) out of the way first if that happens.

3. If you stowed `fish`, install Fisher and the plugins listed in `fish_plugins`:

   ```bash
   fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
   fish -c "fisher update"
   ```

   If you stowed `zsh` instead and want oh-my-zsh:

   ```bash
   sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
   ```

4. If you stowed `touchegg`, enable and start the service:

   ```bash
   systemctl --user enable --now touchegg.service
   ```

5. Set your shell as default, if it isn't already:

   ```bash
   chsh -s "$(which fish)"   # or zsh
   ```

   Log out and back in for the shell change to take effect.

6. If you're on Hyprland, restart it (Super+Esc → Relaunch, or a full logout/login) so `hypr/.config/hypr/` takes effect.

## GNOME restore

`gnome/` isn't a stow package — it's a snapshot of settings, restored manually:

```bash
dconf load / < ~/.dotfiles/gnome/dconf-settings.ini
```

Extensions listed in `gnome/extensions-list.txt` need to be installed by UUID, e.g. via [gnome-shell-extension-installer](https://github.com/brunelli/gnome-shell-extension-installer):

```bash
while read -r uuid; do
    gnome-shell-extension-installer "$uuid" --yes
done < ~/.dotfiles/gnome/extensions-list.txt
```

Reload GNOME Shell (X11: Alt+F2, `r`, Enter; Wayland: log out and back in).

To refresh the snapshot from your current system:

```bash
dconf dump / > ~/.dotfiles/gnome/dconf-settings.ini
gnome-extensions list > ~/.dotfiles/gnome/extensions-list.txt
```

## Uninstalling

```bash
cd ~/.dotfiles
for pkg in fish zsh ghostty hypr waybar omarchy starship touchegg zed; do
    [ -d "$pkg" ] && stow -D "$pkg"
done
```

## Updating

```bash
cd ~/.dotfiles && git pull --recurse-submodules
```
Then re-run `stow <package>` for anything that changed — stow is idempotent, so re-stowing an already-stowed package is safe.

## Troubleshooting: Hyprland keybinds/waybar silently doing nothing

If keybinds or waybar clicks fail silently on an Omarchy/Hyprland/uwsm setup — a command works fine from a terminal but does nothing when triggered via a Hyprland keybind, waybar module click, or `omarchy-toggle-waybar` — check these two things. Both were root causes of exactly this on this machine (fixed 2026-07-13):

1. **PATH mismatch between Hyprland's session environment and your interactive shell.** Anything launched via Hyprland `exec` (keybinds, autostart) or routed through `uwsm-app` (e.g. waybar restarts) inherits the *calling process's* environment, not your shell's — `uwsm-app` doesn't run apps itself, it asks `wayland-wm-app-daemon.service` for a command line and the caller `eval`s it. If Hyprland's captured PATH differs in ordering from your shell's (e.g. `/usr/bin` resolving before `~/.local/bin`, linuxbrew, or mise shims), commands can resolve to the wrong binary or fail outright depending on launch context.

   Fix: get your shell's real PATH (`echo $PATH` in an actual interactive terminal) and pin it explicitly in `hypr/.config/hypr/envs.conf`:

   ```
   env = PATH,<paste your shell's PATH here>
   ```

   This requires a full Hyprland relaunch (Super+Esc → Relaunch) to take effect — `hyprctl reload` is not enough, since `env =` is applied via `setenv()` at config parse time, not by re-executing the process. To verify it actually took effect, don't trust `/proc/<hyprland-pid>/environ` (it only reflects the environment at the original `execve`, not later `setenv` calls) — instead run:

   ```
   hyprctl dispatch exec 'sh -c "env > /tmp/hypr-env.txt"'
   ```

   and check `/tmp/hypr-env.txt` for the PATH a genuinely Hyprland-spawned process receives.

2. **System locale never generated.** If `/etc/locale.conf` sets `LANG=en_US.UTF-8` (or similar) but that locale was never generated, GTK apps can fail to render/map their window when launched non-interactively — no crash, no error dialog, they just don't appear. This is especially relevant for Omarchy's `walker`-based menus (`omarchy-menu`), since `omarchy-menu`'s `menu()` function pipes stderr to `/dev/null`, hiding the "Locale not supported by C library" error entirely.

   Check with `locale -a` — if your `LANG` locale isn't listed, fix it:

   ```bash
   sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
   sudo locale-gen
   ```
