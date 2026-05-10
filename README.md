# G2Ray

> A GitHub Codespaces-based **3x-ui / Xray lab environment** for testing VLESS + XHTTP connections.

## ⚠️ Important Notice

This project is intended for **personal, educational, and legitimate testing only**.

GitHub Codespaces is designed for development environments, not permanent public hosting. Use this project responsibly and in accordance with GitHub’s Terms of Service, your local laws, and any applicable network rules.

Do **not** use this project for abuse, spam, unauthorized access, illegal activity, or long-running public proxy hosting.

---

## Overview

G2Ray creates a GitHub Codespaces development container that automatically installs and starts **3x-ui**, a web panel for managing Xray-based proxy inbounds.

The current setup exposes:

| Port | Purpose |
|---:|---|
| `2053` | 3x-ui web panel |
| `443` | Xray inbound port that you create inside the 3x-ui panel |

After the Codespace starts, the 3x-ui panel should be available at:

```text
https://<CODESPACE_NAME>-2053.app.github.dev/panel/
