# Maple Proxy Tool Design

## Overview

A CLI tool called `maple` that enables accessing geo-restricted websites (Google, OpenAI, etc.)
and applications (Zoom, Teams, Google Meet) from China by routing traffic through a Mac in Canada.

## Architecture

```
+-------------------+    Tailscale Tunnel    +------------------------+
|  Mac (China)      | <-------------------> |  Mac (Canada)           |
|                   |   100.x.x.x network   |                        |
|  Browser          |                       |  Squid Proxy (:3128)   |
|  -> PAC routing   |                       |  Listens on Tailscale  |
|  -> google.com ---|---------------------->|  -> Internet           |
|  -> baidu.com     |  (direct)             |                        |
|                   |                       |                        |
|  Desktop Apps     |                       |  Tailscale Exit Node   |
|  -> maple on      |--- all traffic ------>|  -> Internet           |
+-------------------+                       +------------------------+
```

## Two Modes

### Mode 1: Split Routing (always active)
- PAC file routes specific domains through Squid proxy on Canada Mac
- Domestic traffic goes direct
- Best for daily browsing (Google, Gmail, YouTube, etc.)

### Mode 2: Global Mode (toggle on/off)
- Tailscale Exit Node routes ALL traffic through Canada Mac
- Required for desktop apps (Zoom, Teams, Google Meet)
- Required for API calls (OpenAI, etc.)
- Toggle: `maple on` / `maple off`

## Pre-configured Domains

### Search & Email
google.com, gmail.com, youtube.com, google.ca

### AI Services
openai.com, chat.openai.com, api.openai.com, claude.ai, anthropic.com

### Video Conferencing
zoom.us, teams.microsoft.com, meet.google.com

### Coding Platforms
hackerrank.com, coderpad.io, leetcode.com, codility.com

### Social
twitter.com, x.com, instagram.com, facebook.com, reddit.com

## CLI Interface

```bash
maple on          # Enable global mode (Tailscale Exit Node)
maple off         # Disable global mode, back to split routing
maple add <domain>    # Add domain to PAC proxy list
maple remove <domain> # Remove domain from PAC proxy list
maple list            # Show proxied domains
maple status          # Show current mode + connectivity
maple test            # Test proxy connectivity
```

## Security

- Squid only listens on Tailscale interface (100.x.x.x)
- No public internet exposure
- Traffic between machines encrypted by Tailscale/WireGuard
