#!/bin/sh
# Cross-platform installer for Hola binaries.
# Downloads prebuilt packages from the public Hola releases repo.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/cloudgpu/hola-releases/main/install.sh | sh
# Environment variables:
#   HOLA_VERSION            release version to install (default: 0.6.0)
#   HOLA_RELEASES_REPO      GitHub releases repo, e.g. cloudgpu/hola-releases
#   HOLA_INSTALL_PREFIX     where to put /opt/hola contents for tar installs
#   HOLA_BIN_DIR            where to symlink executables for tar installs
#   HOLA_ENABLE_ZSH         auto-enable zsh plugin by sourcing it in ~/.zshrc (default: 1)

set -e

VERSION="${HOLA_VERSION:-0.6.0}"
RELEASES_REPO="${HOLA_RELEASES_REPO:-cloudgpu/hola-releases}"
BASE_URL="${HOLA_INSTALL_URL:-https://github.com/${RELEASES_REPO}/releases/download/v${VERSION}}"

MACHINE=$(uname -m)
case "$MACHINE" in
    x86_64|amd64) ARCH=x86_64; DEB_ARCH=amd64; TAR_ARCH=amd64 ;;
    arm64|aarch64) ARCH=arm64; DEB_ARCH=arm64; TAR_ARCH=arm64 ;;
    *) echo "Unsupported architecture: $MACHINE" >&2; exit 1 ;;
esac

SUDO=""
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
fi

detect_linux_distro() {
    if [ -r /etc/os-release ]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        echo "$ID ${ID_LIKE:-}"
    else
        echo "unknown"
    fi
}

_hola_enable_zsh() {
    local prefix="$1"
    local zshrc="${HOME}/.zshrc"
    local plugin_path="${prefix}/foundation_apps/hola-zsh/plugin/hola-zsh.plugin.zsh"

    if [ "${HOLA_ENABLE_ZSH:-1}" = "0" ]; then
        return
    fi

    if [ ! -f "$zshrc" ]; then
        echo ""
        echo "Zsh plugin available at:"
        echo "  source ${plugin_path}"
        return
    fi

    # If a hola-zsh source line already exists (possibly from a source build or
    # an old install path), replace it so upgrades keep the plugin working.
    if grep -q "hola-zsh.plugin.zsh" "$zshrc" 2>/dev/null; then
        if grep -qF "source ${plugin_path}" "$zshrc" 2>/dev/null; then
            echo ""
            echo "Hola Zsh plugin is already enabled in ~/.zshrc."
        else
            sed -i "s|source .*hola-zsh\.plugin\.zsh|source ${plugin_path}|" "$zshrc"
            echo ""
            echo "Updated Hola Zsh plugin path in ~/.zshrc to ${plugin_path}."
            echo "Run 'source ~/.zshrc' or open a new terminal to use hola-suggest, hola-explain, and hola-chat."
        fi
        return
    fi

    echo "" >> "$zshrc"
    echo "# Hola Zsh plugin (hola-suggest, hola-explain, hola-chat)" >> "$zshrc"
    echo "source ${plugin_path}" >> "$zshrc"
    echo ""
    echo "Enabled Hola Zsh plugin in ~/.zshrc."
    echo "Run 'source ~/.zshrc' or open a new terminal to use hola-suggest, hola-explain, and hola-chat."
}

_hola_enable_bash() {
    local prefix="$1"
    local bashrc="${HOME}/.bashrc"
    local plugin_path="${prefix}/foundation_apps/hola-zsh/plugin/hola-bash.sh"

    if [ "${HOLA_ENABLE_BASH:-1}" = "0" ]; then
        return
    fi

    if [ ! -f "$bashrc" ]; then
        echo ""
        echo "Bash plugin available at:"
        echo "  source ${plugin_path}"
        return
    fi

    # Update an existing stale source path on upgrade.
    if grep -q "hola-bash.sh" "$bashrc" 2>/dev/null; then
        if grep -qF "source ${plugin_path}" "$bashrc" 2>/dev/null; then
            echo ""
            echo "Hola Bash plugin is already enabled in ~/.bashrc."
        else
            sed -i "s|source .*hola-bash\.sh|source ${plugin_path}|" "$bashrc"
            echo ""
            echo "Updated Hola Bash plugin path in ~/.bashrc to ${plugin_path}."
            echo "Run 'source ~/.bashrc' or open a new terminal to use hola-suggest, hola-explain, and hola-chat."
        fi
        return
    fi

    echo "" >> "$bashrc"
    echo "# Hola Bash plugin (hola-suggest, hola-explain, hola-chat)" >> "$bashrc"
    echo "source ${plugin_path}" >> "$bashrc"
    echo ""
    echo "Enabled Hola Bash plugin in ~/.bashrc."
    echo "Run 'source ~/.bashrc' or open a new terminal to use hola-suggest, hola-explain, and hola-chat."
}

_hola_print_next_steps() {
    local prefix="$1"
    local bin_dir="$2"

    echo ""
    echo "Hola ${VERSION} installed successfully."
    echo ""
    echo "Command-line tools available in: $bin_dir"
    echo "  hola-coder  — agentic coding assistant"
    echo "  hola-admin  — system administration helper"
    echo ""
    echo "Zsh/Bash plugin functions (after enabling):"
    echo "  hola-suggest  — get an editable command suggestion"
    echo "  hola-explain  — explain the last command"
    echo "  hola-chat     — context-aware shell chat"
    echo ""
    echo "To use coding plugins with hola-coder, set:"
    echo "  HOLA_PLUGIN_DIR=${prefix}/foundation_apps/hola-coder/plugins"
    echo ""
    echo "To use the Neovim plugin, add to your init.vim/init.lua:"
    echo "  source ${prefix}/foundation_apps/hola-vim/plugin/hola.vim"
    echo ""
    echo "If your shell cannot find hola-coder/hola-admin yet, run:"
    echo "  rehash        # Zsh"
    echo "  hash -r       # Bash"
    echo "or open a new terminal."
}

glibc_version() {
    # Extract the glibc version from ldd (first line: "ldd (GNU libc) 2.31").
    ldd --version 2>/dev/null | head -n1 | sed -n 's/.*[^0-9.]\([0-9]\+\.[0-9]\+\).*/\1/p'
}

install_deb() {
    local pkg="hola_${VERSION}_${DEB_ARCH}.deb"
    local url="${BASE_URL}/${pkg}"

    # Older glibc containers/distros need the Ubuntu 20.04 (glibc 2.31) build.
    local glibc
    glibc=$(glibc_version)
    if [ -n "$glibc" ] && [ "$(printf '%s\n2.38\n' "$glibc" | sort -V | head -n1)" = "$glibc" ] && [ "$glibc" != "2.38" ]; then
        local legacy_pkg="hola_${VERSION}_${DEB_ARCH}-ubuntu20.04.deb"
        local legacy_url="${BASE_URL}/${legacy_pkg}"
        echo "glibc ${glibc} detected; trying legacy package ${legacy_pkg}..."
        if curl -fsSL "$legacy_url" -o "${TMPDIR}/${legacy_pkg}"; then
            pkg="$legacy_pkg"
            url="$legacy_url"
        else
            echo "Legacy package not available, falling back to standard package."
        fi
    fi

    echo "Downloading Debian package ${pkg}..."
    curl -fsSL "$url" -o "${TMPDIR}/${pkg}"
    echo "Installing with dpkg..."
    $SUDO dpkg -i "${TMPDIR}/${pkg}" || true
    if command -v apt-get >/dev/null 2>&1; then
        echo "Fixing dependencies with apt-get..."
        $SUDO apt-get install -f -y || true
    fi
    _hola_print_next_steps "/opt/hola" "/usr/bin"
    _hola_enable_zsh "/opt/hola"
    _hola_enable_bash "/opt/hola"
}

install_rpm() {
    local pkg="hola-${VERSION}-1.${ARCH}.rpm"
    local url="${BASE_URL}/${pkg}"
    echo "Downloading RPM package ${pkg}..."
    curl -fsSL "$url" -o "${TMPDIR}/${pkg}"
    if command -v dnf >/dev/null 2>&1; then
        echo "Installing with dnf..."
        $SUDO dnf install -y "${TMPDIR}/${pkg}"
    elif command -v yum >/dev/null 2>&1; then
        echo "Installing with yum..."
        $SUDO yum install -y "${TMPDIR}/${pkg}"
    elif command -v zypper >/dev/null 2>&1; then
        echo "Installing with zypper..."
        $SUDO zypper install -y "${TMPDIR}/${pkg}"
    else
        echo "Installing with rpm..."
        $SUDO rpm -Uvh "${TMPDIR}/${pkg}"
    fi
    _hola_print_next_steps "/opt/hola" "/usr/bin"
    _hola_enable_zsh "/opt/hola"
    _hola_enable_bash "/opt/hola"
}

install_arch_pkg() {
    local pkg="hola-${VERSION}-1-${ARCH}.pkg.tar.zst"
    local url="${BASE_URL}/${pkg}"
    echo "Downloading Arch package ${pkg}..."
    curl -fsSL "$url" -o "${TMPDIR}/${pkg}"
    echo "Installing with pacman..."
    $SUDO pacman -U --noconfirm "${TMPDIR}/${pkg}"
    _hola_print_next_steps "/opt/hola" "/usr/bin"
    _hola_enable_zsh "/opt/hola"
    _hola_enable_bash "/opt/hola"
}

install_tarball() {
    local os="$1"
    local pkg="hola-${VERSION}-${os}-${TAR_ARCH}.tar.gz"
    local url="${BASE_URL}/${pkg}"

    if [ -n "${HOLA_INSTALL_PREFIX:-}" ]; then
        PREFIX="$HOLA_INSTALL_PREFIX"
    elif [ "$(id -u)" -eq 0 ] || [ -w /opt ]; then
        PREFIX="/opt/hola"
    else
        PREFIX="${HOME}/.local/hola"
    fi

    if [ -n "${HOLA_BIN_DIR:-}" ]; then
        BIN_DIR="$HOLA_BIN_DIR"
    elif [ "$PREFIX" = "/opt/hola" ]; then
        BIN_DIR="/usr/local/bin"
    else
        BIN_DIR="${HOME}/.local/bin"
    fi

    if [ ! -w "$(dirname "$PREFIX")" ] || { [ -e "$PREFIX" ] && [ ! -w "$PREFIX" ]; }; then
        if command -v sudo >/dev/null 2>&1; then
            SUDO="sudo"
        fi
    fi

    echo "Downloading ${pkg}..."
    if ! curl -fsSL "$url" -o "${TMPDIR}/${pkg}"; then
        echo "Failed to download ${url}" >&2
        echo "This platform may not have a prebuilt binary yet." >&2
        echo "Request one at https://github.com/${RELEASES_REPO}/issues" >&2
        exit 1
    fi

    echo "Extracting..."
    tar -xzf "${TMPDIR}/${pkg}" -C "$TMPDIR"

    if [ ! -d "${TMPDIR}/opt/hola" ]; then
        echo "Tarball layout unexpected: missing opt/hola" >&2
        exit 1
    fi

    if [ -d "$PREFIX" ]; then
        echo "Backing up existing installation to ${PREFIX}.bak..."
        $SUDO rm -rf "${PREFIX}.bak"
        $SUDO mv "$PREFIX" "${PREFIX}.bak"
    fi

    echo "Installing Hola to ${PREFIX}..."
    $SUDO mkdir -p "$PREFIX"
    $SUDO cp -R -p "${TMPDIR}/opt/hola/." "$PREFIX/"

    $SUDO mkdir -p "$BIN_DIR"
    $SUDO ln -sf "$PREFIX/foundation_apps/hola-admin/bin/hola-admin" "$BIN_DIR/hola-admin"
    $SUDO ln -sf "$PREFIX/foundation_apps/hola-coder/bin/hola-coder" "$BIN_DIR/hola-coder"

    if ! echo "$PATH" | tr ':' '\n' | grep -qx "$BIN_DIR"; then
        echo ""
        echo "$BIN_DIR is not on your PATH. Add it with:"
        echo "  export PATH=\"$BIN_DIR:\$PATH\""
        case "${SHELL##*/}" in
            zsh) echo "  echo 'export PATH=\"$BIN_DIR:\$PATH\"' >> ~/.zshrc" ;;
            bash) echo "  echo 'export PATH=\"$BIN_DIR:\$PATH\"' >> ~/.bashrc" ;;
        esac
    fi

    _hola_print_next_steps "$PREFIX" "$BIN_DIR"
    _hola_enable_zsh "$PREFIX"
    _hola_enable_bash "$PREFIX"
}

if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required but not installed." >&2
    exit 1
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

OS=$(uname -s)
case "$OS" in
    Linux)
        DISTRO=$(detect_linux_distro)
        case "$DISTRO" in
            *debian*|*ubuntu*|*mint*|*pop*)
                install_deb
                ;;
            *fedora*|*rhel*|*centos*|*rocky*|*alma*|*opensuse*|*suse*)
                install_rpm
                ;;
            *arch*|*manjaro*)
                install_arch_pkg
                ;;
            *)
                echo "No native package for this distro. Falling back to tarball."
                install_tarball linux
                ;;
        esac
        ;;
    Darwin)
        install_tarball darwin
        ;;
    FreeBSD)
        install_tarball freebsd
        ;;
    *)
        echo "Unsupported operating system: $OS" >&2
        echo "Request a binary at https://github.com/${RELEASES_REPO}/issues" >&2
        exit 1
        ;;
esac

echo ""
echo "Done."
