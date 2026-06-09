#!/usr/bin/env bash
set -euo pipefail

# Post-install bootstrap for Henri's Arch/Hyprland workstation.
# Run this from the installed Arch system as the target user, not from arch-chroot.

CONFIG_REPO_URL="${CONFIG_REPO_URL:-git@github.com:henri-32/myconfigs.git}"
CONFIG_DIR="${CONFIG_DIR:-$HOME/projects/dotfiles}"
INSTALL_TEX="${INSTALL_TEX:-0}"
INSTALL_DOCKER="${INSTALL_DOCKER:-0}"
INSTALL_EMBEDDED="${INSTALL_EMBEDDED:-1}"

PACMAN=(sudo pacman --needed --noconfirm -S)
NPM=(sudo npm install -g)

require_arch() {
	if [[ ! -f /etc/arch-release ]]; then
		echo "This script is intended for Arch Linux." >&2
		exit 1
	fi
}

require_user() {
	if [[ "${EUID}" -eq 0 ]]; then
		echo "Run as your normal user; sudo is used only where needed." >&2
		exit 1
	fi
}

install_packages() {
	local base=(
		base-devel linux-firmware amd-ucode
		git openssh rsync curl wget ca-certificates gnupg
		networkmanager bluez bluez-utils
		man-db man-pages bash-completion
		htop jq ripgrep fd fzf bat eza
		unzip zip p7zip zstd dos2unix redshift
		fwupd usbutils tlp zoxide
	)

	local terminal_workflow=(
		tmux neovim yazi
		ffmpegthumbnailer poppler imagemagick xdg-utils file
		wl-clipboard xclip
	)

	local hyprland_stack=(
		hyprland hyprpaper hyprpolkitagent 
		xdg-desktop-portal-hyprland
		foot waybar mako wofi
		grim slurp imv mpv
		brightnessctl playerctl pavucontrol
		pipewire pipewire-alsa pipewire-pulse wireplumber
		polkit-kde-agent qt5-wayland qt6-wayland
		mesa vulkan-radeon libva-mesa-driver wev
	)

	local desktop_apps=(
		firefox chromium
		zettlr pandoc-cli
		libreoffice-fresh libreoffice-fresh-de
		okular zathura zathura-pdf-poppler
		hunspell hunspell-de hyphen-de mythes-de languagetool
	)

	local dev=(
		gcc clang clang-tools-extra cmake ninja bear pkgconf ccache
		python python-pip python-virtualenv python-pipx
		nodejs npm jdk-openjdk
		lua-language-server pyright ruff
		rustup
	)

	local embedded=(
		avr-gcc avr-libc avrdude teensy_loader_cli
	)

	local tex=(
		texlive-basic texlive-binextra texlive-latex
		texlive-latexrecommended texlive-fontsrecommended
	)

	local npm=(
		@openai/codex
	)

	local nvim_plugins=(
		git@github.com:catppuccin/nvim.git
		git@github.com:nvim-telescope/telescope.nvim
		git@github.com:nvim-lua/plenary.nvim.git
		git@github.com:stevearc/quicker.nvim.git
		git@github.com:hrsh7th/nvim-cmp.git
		git@github.com:neovim/nvim-lspconfig.git
		git@github.com:mikavilpas/yazi.nvim.git
	)

	"${PACMAN[@]}" "${base[@]}"
	"${PACMAN[@]}" "${terminal_workflow[@]}"
	"${PACMAN[@]}" "${hyprland_stack[@]}"
	"${PACMAN[@]}" "${desktop_apps[@]}"
	"${PACMAN[@]}" "${dev[@]}"
	"${NPM[@]}" "${npm[@]}"
	install_nvim_plugins "${nvim_plugins[@]}"

	if [[ "${INSTALL_EMBEDDED}" == "1" ]]; then
		"${PACMAN[@]}" "${embedded[@]}"
	fi

	if [[ "${INSTALL_TEX}" == "1" ]]; then
		"${PACMAN[@]}" "${tex[@]}"
	fi

	if [[ "${INSTALL_DOCKER}" == "1" ]]; then
		"${PACMAN[@]}" docker docker-compose
		sudo systemctl enable --now docker.service
		sudo usermod -aG docker "$USER"
	fi
}

install_nvim_plugins() {
	local pack_dir="$HOME/.local/share/nvim/site/pack/manual/start"
	local repo name target

	mkdir -p "$pack_dir"

	for repo in "$@"; do
		name="${repo##*/}"
		name="${name%.git}"
		target="$pack_dir/$name"

		if [[ -d "$target/.git" ]]; then
			git -C "$target" pull --ff-only
		else
			git clone "$repo" "$target"
		fi
	done
}

enable_services() {
	systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service || true
	sudo systemctl enable --now NetworkManager.service || true
	sudo systemctl enable --now bluetooth.service || true
	sudo systemctl enable --now sshd.service || true
}

clone_or_update_config() {
	mkdir -p "$HOME/projects"

	if [[ -d "${CONFIG_DIR}/.git" ]]; then
		git -C "$CONFIG_DIR" pull --ff-only
	else
		git clone "$CONFIG_REPO_URL" "$CONFIG_DIR"
	fi

	git -C "$CONFIG_DIR" submodule update --init --recursive || true
}

backup_path() {
	local path="$1"

	if [[ -e "$path" || -L "$path" ]]; then
		mv "$path" "${path}.bak.$(date +%Y%m%d%H%M%S)"
	fi
}

link_config() {
	local source="$1"
	local target="$2"

	if [[ ! -e "$source" ]]; then
		echo "Missing config source: $source" >&2
		return 1
	fi

	mkdir -p "$(dirname "$target")"

	if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
		return 0
	fi

	backup_path "$target"
	ln -s "$source" "$target"
}

install_configs() {
	link_config "$CONFIG_DIR/foot" "$HOME/.config/foot"
	link_config "$CONFIG_DIR/hypr" "$HOME/.config/hypr"
	link_config "$CONFIG_DIR/yazi" "$HOME/.config/yazi"
	link_config "$CONFIG_DIR/tmux" "$HOME/.config/tmux"

	# The current repo has a trailing space in the nvim directory name.
	link_config "$CONFIG_DIR/nvim " "$HOME/.config/nvim"

	mkdir -p "$HOME/.tmux/plugins"
	if [[ ! -d "$HOME/.tmux/plugins/tpm/.git" ]]; then
		git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
	fi
}

prepare_user_env() {
	mkdir -p "$HOME/Pictures/wallpaper" "$HOME/.local/bin"

	if ! grep -q 'Henri Arch bootstrap' "$HOME/.bashrc" 2>/dev/null; then
		cat >>"$HOME/.bashrc" <<'EOF'

# Henri Arch bootstrap
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"
alias tmux_coding="$HOME/projects/scripts/setup_scripts/tmux_coding.sh"
alias nvim-server="nvim --listen /tmp/nvim-main.sock"
alias lucid='chromium --ozone-platform=wayland --app=https://lucid.app'
alias projectstat='cd "$HOME" && ./projects/scripts/project_status/status.sh'
EOF
	fi

	rustup default stable || true
	python -m pipx ensurepath || true
}

print_next_steps() {
	cat <<EOF

Bootstrap complete.

Next manual checks:
  1. Copy or recreate $HOME/Pictures/wallpaper/boat.jpg for hyprpaper.
  2. Re-login so group, PATH and user services are refreshed.
  3. In tmux, press prefix + I to install TPM plugins.
  4. In Neovim, run :checkhealth and let plugins install/update if prompted.
  5. If Docker was enabled, log out once before using it without sudo.

Optional reruns:
  INSTALL_TEX=1 ./bootstrap-arch.sh
  INSTALL_DOCKER=1 ./bootstrap-arch.sh
  INSTALL_EMBEDDED=0 ./bootstrap-arch.sh
EOF
}

main() {
	require_arch
	require_user
	install_packages
	enable_services
	clone_or_update_config
	install_configs
	prepare_user_env
	print_next_steps
}

main "$@"
