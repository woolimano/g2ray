#!/usr/bin/env bash
set -euo pipefail

XUI_DIR="/usr/local/x-ui"
XUI_DB_DIR="/etc/x-ui"
XUI_LOG_DIR="/var/log/x-ui"

mkdir -p "$XUI_DIR" "$XUI_DB_DIR" "$XUI_LOG_DIR"

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|x64|amd64) XUI_ARCH="amd64" ;;
  aarch64|arm64) XUI_ARCH="arm64" ;;
  armv7*|armv7) XUI_ARCH="armv7" ;;
  armv6*|armv6) XUI_ARCH="armv6" ;;
  armv5*|armv5) XUI_ARCH="armv5" ;;
  i*86|x86) XUI_ARCH="386" ;;
  s390x) XUI_ARCH="s390x" ;;
  *) XUI_ARCH="amd64" ;;
esac

echo "Detected architecture: $ARCH -> $XUI_ARCH"

LATEST_TAG="$(curl -fsSL https://api.github.com/repos/MHSanaei/3x-ui/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"

if [ -z "$LATEST_TAG" ]; then
  echo "Could not detect latest 3x-ui tag from GitHub API."
  exit 1
fi

echo "Latest 3x-ui release: $LATEST_TAG"

cd /tmp
wget -O x-ui.tar.gz "https://github.com/MHSanaei/3x-ui/releases/download/${LATEST_TAG}/x-ui-linux-${XUI_ARCH}.tar.gz"

rm -rf "$XUI_DIR"
mkdir -p "$XUI_DIR"

tar -xzf x-ui.tar.gz

# The tarball normally extracts an x-ui/ folder.
if [ -d "/tmp/x-ui" ]; then
  cp -a /tmp/x-ui/. "$XUI_DIR/"
else
  echo "Unexpected archive layout."
  ls -la /tmp
  exit 1
fi

chmod +x "$XUI_DIR/x-ui" || true
chmod +x "$XUI_DIR/bin/"* || true

# CLI helper, similar to normal 3x-ui install.
cat > /usr/bin/x-ui <<'EOF'
#!/usr/bin/env bash
exec /usr/local/x-ui/x-ui "$@"
EOF
chmod +x /usr/bin/x-ui

# Configure the panel for Codespaces.
# IMPORTANT: These are intentionally simple defaults for a lab.
# Change them inside the panel after first login.
"$XUI_DIR/x-ui" setting \
  -username "admin" \
  -password "adminadmin" \
  -port "2053" \
  -webBasePath "panel" || true

echo "3x-ui installed in $XUI_DIR"
echo "Panel configured on port 2053 with path /panel"
