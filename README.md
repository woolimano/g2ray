# G2Ray

> A GitHub Codespaces-based **3x-ui / Xray lab environment** for testing VLESS + XHTTP connections.

---

## ⚠️ Important Notice

This project is intended for **personal, educational, and legitimate testing only**.

GitHub Codespaces is a development environment, not a permanent public hosting platform. Use this project responsibly and in accordance with:

- GitHub’s Terms of Service
- Your local laws and regulations
- Any applicable network or service rules

Do **not** use this project for abuse, spam, unauthorized access, illegal activity, high-volume public proxy hosting, or any activity that violates GitHub’s policies.

---

## Overview

G2Ray creates a GitHub Codespaces devcontainer that automatically installs and starts **3x-ui**, a web panel for managing Xray-based proxy inbounds.

The setup exposes two main ports:

| Port | Purpose |
|---:|---|
| `2053` | 3x-ui web panel |
| `443` | Xray inbound port created inside 3x-ui |

After the Codespace starts, the 3x-ui panel should be available at:

```text
https://<CODESPACE_NAME>-2053.app.github.dev/panel/
```

The external VLESS/XHTTP host will usually look like:

```text
<CODESPACE_NAME>-443.app.github.dev
```

This setup only works in places where GitHub Codespaces and GitHub forwarded ports are reachable.

---

## Requirements

You need:

- A GitHub account
- GitHub Codespaces enabled
- Available Codespaces quota
- A client app that supports **VLESS + XHTTP**
- A network where GitHub Codespaces and GitHub forwarded ports are accessible

Recommended clients:

- Recent Xray-core based desktop clients
- Recent Xray-core based Android clients
- Any client that supports VLESS + XHTTP manually

Some clients may not support importing XHTTP links directly. If import fails, enter the connection details manually.

---

## Repository Structure

This version only needs:

```text
Dockerfile
.devcontainer/devcontainer.json
README.md
```

The Dockerfile creates these helper scripts inside the container:

```text
/app/auto-start-3xui.sh
/app/check-3xui.sh
```

You do **not** need the old simple-Xray files anymore:

```text
install.sh
install-3x-ui.sh
startup.sh
config.json
```

---

## What Happens During Setup

When the Codespace builds, the Dockerfile:

1. Installs Debian dependencies
2. Downloads the latest 3x-ui release
3. Installs 3x-ui into:

```text
/usr/local/x-ui
```

4. Configures the panel on port:

```text
2053
```

5. Creates the auto-start helper:

```text
/app/auto-start-3xui.sh
```

6. Creates the diagnostic helper:

```text
/app/check-3xui.sh
```

Then `.devcontainer/devcontainer.json` runs:

```bash
/app/auto-start-3xui.sh
```

through `postStartCommand` whenever the Codespace container starts.

---

## Setup

1. Open this repository on GitHub.
2. Click the green **Code** button.
3. Open the **Codespaces** tab.
4. Click **Create codespace on main**.
5. Wait for the container to build.
6. Open the **Ports** tab.
7. Open port `2053`.

The panel URL should look like:

```text
https://<CODESPACE_NAME>-2053.app.github.dev/panel/
```

---

## Default Panel Login

Default lab credentials:

```text
Username: admin
Password: adminadmin
```

Change the username and password immediately after logging in.

Recommended:

- Change username
- Change password
- Keep panel port `2053` private
- Do not share the panel URL
- Do not expose admin credentials
- Do not store private keys, UUIDs, or credentials in a public repository

---

## Verify 3x-ui Is Running

Run:

```bash
/app/check-3xui.sh
```

You should see port `2053` listening.

You can also check manually:

```bash
ss -ltnp | grep 2053
```

Expected result:

```text
LISTEN ... :2053
```

Test the local panel:

```bash
curl -i http://127.0.0.1:2053/panel/
```

If the panel is running, you should get an HTTP response such as:

```text
HTTP/1.1 200 OK
```

or a redirect/login page.

---

## Open the Panel

Print your panel URL:

```bash
echo "https://${CODESPACE_NAME}-2053.app.github.dev/panel/"
```

Then open it in your browser.

Or open it from:

```text
VS Code / Codespaces → Ports tab → 2053 → Open in Browser
```

---

## Create a VLESS + XHTTP Inbound

Inside the 3x-ui panel, create a new inbound.

Use these settings:

| Setting | Value |
|---|---|
| Protocol | `VLESS` |
| Listen IP | `0.0.0.0` |
| Port | `443` |
| UUID | Your chosen UUID |
| Transport | `XHTTP` |
| Path | `/` |
| Mode | `packet-up` |
| TLS inside 3x-ui | `none` |

### Why TLS Should Be `none` Inside 3x-ui

GitHub Codespaces provides the external HTTPS forwarded URL:

```text
https://<CODESPACE_NAME>-443.app.github.dev
```

So your client connects with TLS to GitHub’s forwarded domain.

Inside the Codespace, 3x-ui/Xray should receive the forwarded traffic without managing its own TLS certificate.

---

## Forward Port 443

Open the **Ports** tab.

Make sure port `443` is forwarded.

If it is not visible:

1. Open the **Ports** tab.
2. Click **Add Port**.
3. Add:

```text
443
```

4. Set visibility as needed.
5. Open/copy the forwarded host.

Your external host should be:

```text
<CODESPACE_NAME>-443.app.github.dev
```

Print it:

```bash
echo "${CODESPACE_NAME}-443.app.github.dev"
```

---

## Client Connection Fields

Use these values in your VLESS/Xray client:

```text
Protocol:   VLESS
Address:    <CODESPACE_NAME>-443.app.github.dev
Port:       443
UUID:       your-client-uuid
Encryption: none
Security:   tls
SNI:        <CODESPACE_NAME>-443.app.github.dev
Type:       xhttp
Path:       /
Mode:       packet-up
```

Example VLESS link format:

```text
vless://YOUR_UUID@<CODESPACE_NAME>-443.app.github.dev:443?security=tls&type=xhttp&path=%2F&mode=packet-up&sni=<CODESPACE_NAME>-443.app.github.dev#G2Ray-Codespace
```

Some clients do not import XHTTP links perfectly. If the link import fails, enter the settings manually.

---

## Codespaces Quota

GitHub Free personal accounts include a monthly Codespaces quota.

At the time of writing, GitHub lists:

```text
120 core-hours per month
15 GB-month storage
```

A 2-core Codespace uses about 2 core-hours per wall-clock hour.

So:

```text
120 core-hours ÷ 2 cores = about 60 hours of runtime
```

To save quota:

- Stop your Codespace when not in use
- Delete unused Codespaces
- Avoid running multiple Codespaces
- Use the smallest machine type that works

---

## Port Visibility

Recommended visibility:

| Port | Recommended Visibility |
|---:|---|
| `2053` panel | Private |
| `443` Xray inbound | Public only if needed |

Keep the admin panel private whenever possible.

---

# Troubleshooting

## 1. Panel URL Returns `502 Bad Gateway`

This usually means Codespaces forwarded the port, but nothing is listening inside the container.

Run:

```bash
/app/check-3xui.sh
```

Check if port `2053` is listening:

```bash
ss -ltnp | grep 2053
```

If there is no output, start 3x-ui manually:

```bash
/app/auto-start-3xui.sh
```

Then check again:

```bash
ss -ltnp | grep 2053
```

Also test locally:

```bash
curl -i http://127.0.0.1:2053/panel/
```

If local curl works but the browser still shows `502`, remove and re-add port `2053` from the Codespaces **Ports** tab.

---

## 2. `/app/check-3xui.sh` Says 3x-ui Is Not Listening

Run:

```bash
cat /tmp/3x-ui-autostart.log
cat /tmp/3x-ui.log
```

Then try:

```bash
/app/auto-start-3xui.sh
```

If it still fails, check the binary:

```bash
ls -la /usr/local/x-ui
/usr/local/x-ui/x-ui setting -show true
```

Expected files include:

```text
/usr/local/x-ui/x-ui
/usr/local/x-ui/bin/
```

---

## 3. `curl` Cannot Connect to `127.0.0.1:2053`

Example error:

```text
curl: (7) Failed to connect to 127.0.0.1 port 2053
```

This means the panel is not running.

Fix:

```bash
/app/auto-start-3xui.sh
```

Then:

```bash
ss -ltnp | grep 2053
curl -i http://127.0.0.1:2053/panel/
```

---

## 4. Port `2053` Does Not Appear in the Codespaces Ports Tab

Manually add it:

1. Open the **Ports** tab.
2. Click **Add Port**.
3. Enter:

```text
2053
```

4. Set protocol to HTTP.
5. Open the generated forwarded URL.

---

## 5. Login Page Opens, but Credentials Do Not Work

Default credentials in this setup are:

```text
Username: admin
Password: adminadmin
```

If they do not work, reset them:

```bash
/usr/local/x-ui/x-ui setting \
  -username "admin" \
  -password "adminadmin" \
  -port "2053" \
  -webBasePath "panel"
```

Restart:

```bash
pkill -f "/usr/local/x-ui/x-ui" || true
/app/auto-start-3xui.sh
```

---

## 6. Panel Opens at `/`, but `/panel/` Does Not Work

Check current settings:

```bash
/usr/local/x-ui/x-ui setting -show true
```

Set the panel path again:

```bash
/usr/local/x-ui/x-ui setting -webBasePath "panel"
```

Restart:

```bash
pkill -f "/usr/local/x-ui/x-ui" || true
/app/auto-start-3xui.sh
```

Then open:

```bash
echo "https://${CODESPACE_NAME}-2053.app.github.dev/panel/"
```

---

## 7. Xray Inbound Is Not Listening on Port `443`

After creating the inbound in the 3x-ui panel, run:

```bash
ss -ltnp | grep 443
```

If nothing is listening, recheck the inbound settings:

```text
Protocol: VLESS
Port: 443
Listen IP: 0.0.0.0
Transport: XHTTP
Path: /
Mode: packet-up
TLS inside panel: none
```

Then restart the inbound from the 3x-ui panel.

---

## 8. Port `443` Is Not Visible in the Codespaces Ports Tab

Manually add it:

1. Open the **Ports** tab.
2. Click **Add Port**.
3. Enter:

```text
443
```

Then copy the forwarded host:

```bash
echo "${CODESPACE_NAME}-443.app.github.dev"
```

---

## 9. Client Imports the VLESS Link but Cannot Connect

Try manual client configuration instead of link import.

Use:

```text
Address:    <CODESPACE_NAME>-443.app.github.dev
Port:       443
UUID:       your-client-uuid
Encryption: none
Security:   tls
SNI:        <CODESPACE_NAME>-443.app.github.dev
Type:       xhttp
Path:       /
Mode:       packet-up
```

Also check:

```bash
ss -ltnp | grep 443
```

If port `443` is not listening inside Codespaces, the inbound is not running.

---

## 10. Client Does Not Support XHTTP

Some clients may not support XHTTP or may not support importing XHTTP links.

Try:

- Recent Xray-core based clients
- Manual profile entry
- Updating the client/core
- Testing another transport inside 3x-ui

---

## 11. Codespace Rebuilt but Panel Is Gone

Run:

```bash
/app/check-3xui.sh
```

If needed:

```bash
/app/auto-start-3xui.sh
```

If the container image was rebuilt, 3x-ui should be reinstalled automatically from the Dockerfile.

---

## 12. Codespace Stopped After Inactivity

Start the Codespace again from GitHub.

Then run:

```bash
/app/check-3xui.sh
```

If the panel is not running:

```bash
/app/auto-start-3xui.sh
```

---

## 13. You Changed Dockerfile or devcontainer.json but Nothing Changed

Rebuild the container:

```text
Cmd/Ctrl + Shift + P
→ Codespaces: Rebuild Container
```

Then check:

```bash
/app/check-3xui.sh
```

---

## 14. 3x-ui Process Is Running, but Port `2053` Is Still Not Listening

Kill the existing process and restart cleanly:

```bash
pkill -f "/usr/local/x-ui/x-ui" || true
/app/auto-start-3xui.sh
```

Check again:

```bash
ss -ltnp | grep 2053
cat /tmp/3x-ui.log
```

---

## 15. `postStartCommand` Did Not Run

Check:

```bash
cat /tmp/3x-ui-autostart.log
```

If the file does not exist, the container may not have restarted after your `devcontainer.json` change.

Rebuild the container:

```text
Cmd/Ctrl + Shift + P
→ Codespaces: Rebuild Container
```

Then check:

```bash
cat /tmp/3x-ui-autostart.log
/app/check-3xui.sh
```

---

## 16. Still Not Working

Collect these outputs:

```bash
/app/check-3xui.sh
```

```bash
cat /tmp/3x-ui-autostart.log
```

```bash
cat /tmp/3x-ui.log
```

```bash
/usr/local/x-ui/x-ui setting -show true
```

```bash
ss -ltnp | grep -E ':2053|:443'
```

Then review:

- Is port `2053` listening?
- Is port `443` listening after creating the inbound?
- Is the Codespaces port forwarded?
- Is the correct forwarded URL being opened?
- Is the panel path `/panel/`?
- Is your client using the correct SNI?
- Is the client using XHTTP with path `/` and mode `packet-up`?

---

## Security Notes

- Change the default username and password immediately.
- Keep port `2053` private.
- Do not share the panel URL.
- Do not expose admin credentials.
- Do not store sensitive keys in public repositories.
- Do not use this as a permanent public service.
- Follow GitHub’s Terms of Service and applicable laws.

---

## Limitations

This setup is for **testing and development**.

It is not designed for:

- Permanent hosting
- Production traffic
- High-volume proxying
- Abuse or unauthorized traffic
- Guaranteed uptime

Codespaces can stop, sleep, rebuild, exhaust quota, or change forwarded URLs.

---

## Disclaimer

This project is provided for educational and legitimate testing only.

The author is not responsible for misuse, account restrictions, service interruptions, legal consequences, quota usage, or violations of third-party terms.

Users are responsible for how they deploy and use this project.

---

## License

This project is open-source. See the `LICENSE` file for details.
