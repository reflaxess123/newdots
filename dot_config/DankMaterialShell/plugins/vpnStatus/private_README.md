# VPN Status Plugin for DankMaterialShell

A DMS plugin to monitor and control sing-box VPN with domain traffic visualization.

## Features

- VPN status indicator in the bar (green when active)
- Toggle VPN on/off from popup
- View recent domains routed through proxy
- View recent domains routed directly
- Auto-refresh domain lists

## Screenshot

![VPN Status Plugin](screenshot.png)

## Installation

1. Clone to DMS plugins directory:
```bash
git clone https://github.com/reflaxess123/vpnstatus.git ~/.config/DankMaterialShell/plugins/vpnStatus
```

2. Copy the domain parser script:
```bash
cp vpn-domains.py ~/.config/hypr/scripts/
chmod +x ~/.config/hypr/scripts/vpn-domains.py
```

3. Enable in DMS Settings → Plugins → VPN Status

4. Restart DMS:
```bash
dms kill && dms run &
```

## Requirements

- DankMaterialShell
- sing-box VPN client
- Python 3
- sing-box logging enabled to `~/.local/share/singbox-traffic.log`

## sing-box config

Make sure your sing-box config has logging enabled:

```json
{
  "log": {
    "level": "debug",
    "timestamp": true,
    "output": "/home/YOUR_USER/.local/share/singbox-traffic.log"
  }
}
```

## Files

- `plugin.json` - Plugin manifest
- `VpnStatusWidget.qml` - Main widget component
- `vpn-domains.py` - Domain parser script

## License

MIT
