#!/usr/bin/env bash
set -euo pipefail

APPDIR="$HOME/.local/share/applications"
ICONDIR="$HOME/.local/share/icons"
DESTDIR="$HOME/.local/AppImages"
APPIMAGE_EXEC="appimage-run" # Change this if needed

# ANSI colors
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

# For spaces / padding format for first column
PADDING="%-8s"

pad_format() {
  # helper to print the prefixed padded label (does not add newline)
  printf "$PADDING" "$1"
}

log() {
  # message on a new line
  printf "${PADDING} %s\n" "[*]" "$1"
}
success() {
  printf "${GREEN}${PADDING}${RESET} %s\n" "[OK]" "$1"
}
error() {
  printf "${RED}${PADDING}${RESET} %s\n" "[ERROR]" "$1" >&2
}
warn() {
  printf "${YELLOW}${PADDING}${RESET} %s\n" "[WARN]" "$1"
}

prompt() {
  local message="$1"
  local arg="${2:-}"
  # don't add newline so `read` happens on same line
  printf "${YELLOW}${PADDING}${RESET} %s" "[?]" "$message${arg:+ [$arg]}: "
}

# --- Validate argument
if [ "$#" -eq 0 ]; then
  error "No AppImage file provided."
  warn "USAGE: appimage-install path/to/AppImage"
  exit 1
fi

APPIMAGE="$1"
if [ ! -f "$APPIMAGE" ]; then
  error "File not found: $APPIMAGE"
  exit 1
fi

FILENAME=$(basename -- "$APPIMAGE")
DEFAULT_NAME="${FILENAME%%.*}"

prompt "How should this application appear in your system menus?" "$DEFAULT_NAME"
read -r DISPLAY_NAME
DISPLAY_NAME="${DISPLAY_NAME:-$DEFAULT_NAME}"

# --- Generate file name ID (lowercase, replace non-alnum with -, squeeze -)
FILE_ID=$(echo "$DISPLAY_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g; s/--*/-/g; s/^-//; s/-$//')
RENAMED_APPIMAGE="$DESTDIR/$FILE_ID.AppImage"
DESKTOP_FILE="$APPDIR/$FILE_ID.desktop"

mkdir -p "$APPDIR" "$ICONDIR"

if [ ! -d "$DESTDIR" ]; then
  mkdir -p "$DESTDIR"
  success "Created AppImage directory at $DESTDIR"
else
  log "Using existing AppImage directory at $DESTDIR"
fi

# --- Make executable
if [ ! -x "$APPIMAGE" ]; then
  chmod +x "$APPIMAGE"
  success "Execution permission applied to $APPIMAGE"
fi

# --- Move and rename AppImage
if [ "$APPIMAGE" != "$RENAMED_APPIMAGE" ]; then
  if [ -f "$RENAMED_APPIMAGE" ]; then
    error "An AppImage with name '$FILE_ID.AppImage' already exists in $DESTDIR."
    exit 1
  fi
  mv -- "$APPIMAGE" "$RENAMED_APPIMAGE"
  success "AppImage moved to $RENAMED_APPIMAGE"
else
  success "AppImage already in the correct location."
fi

# --- Ensure it's still executable
if [ ! -x "$RENAMED_APPIMAGE" ]; then
  chmod +x "$RENAMED_APPIMAGE"
  success "Execution permission applied to $RENAMED_APPIMAGE"
fi

# --- Extract icon
log "Searching for icons in the AppImage..."
ICON_PATH=""
TMPDIR=$(mktemp -d)
# ensure tmpdir is removed on exit
trap 'rm -rf -- "${TMPDIR:-}"' EXIT

# Try to extract using 7z or bsdtar if available
if command -v 7z >/dev/null 2>&1; then
  7z x "$RENAMED_APPIMAGE" -o"$TMPDIR" >/dev/null 2>&1 || true
elif command -v bsdtar >/dev/null 2>&1; then
  bsdtar -xf "$RENAMED_APPIMAGE" -C "$TMPDIR" >/dev/null 2>&1 || true
else
  # some AppImages are actually squashfs; try unsquashfs if present
  if command -v unsquashfs >/dev/null 2>&1; then
    unsquashfs -d "$TMPDIR" "$RENAMED_APPIMAGE" >/dev/null 2>&1 || true
  fi
fi

FOUND_ICON=$(find "$TMPDIR" -type f \( -iname '*.png' -o -iname '*.svg' \) 2>/dev/null | head -n 1 || true)

if [ -n "$FOUND_ICON" ]; then
  EXT="${FOUND_ICON##*.}"
  ICON_FILENAME="$FILE_ID.$EXT"
  cp -- "$FOUND_ICON" "$ICONDIR/$ICON_FILENAME"
  ICON_PATH="$ICONDIR/$ICON_FILENAME"
  success "Icon extracted to $ICON_PATH"
else
  log "No icon found, fallback to name as icon."
  ICON_PATH="$FILE_ID"
fi

# TMPDIR will be removed by trap

# --- Create .desktop file
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=$DISPLAY_NAME
Exec=$APPIMAGE_EXEC "$RENAMED_APPIMAGE"
Icon=$ICON_PATH
Type=Application
Categories=Utility;
Terminal=false
EOF

success ".desktop launcher created at $DESKTOP_FILE"

# --- Optional edit
prompt "Do you want to manually edit the .desktop file? [y/N]"
read -r EDIT_DESKTOP
if [[ "$EDIT_DESKTOP" =~ ^[Yy]$ ]]; then
  "${EDITOR:-nano}" "$DESKTOP_FILE"
fi

# --- Update desktop db
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$APPDIR" >/dev/null 2>&1 || true
fi

success "$DISPLAY_NAME was successfully installed and integrated."

