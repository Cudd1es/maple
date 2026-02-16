# Maple

Route traffic through your Canada Mac to access geo-restricted websites and services.

## How It Works

```
Mac (China)  ----Tailscale----->  Mac (Canada)  ----->  Internet
   |                                  |
   |-- PAC split routing (browser)    |-- Squid proxy (:3128)
   |-- Global mode (all apps)        |-- Tailscale Exit Node
```

**Two modes:**
- **Split mode** (default): Only configured domains go through Canada (browser only)
- **Global mode**: All traffic goes through Canada (for Zoom/Teams/API calls)

## Prerequisites

- [Tailscale](https://tailscale.com/download) installed and connected on both Macs
- [Homebrew](https://brew.sh) installed on both Macs

## Setup

### 1. Server (Canada Mac)

```bash
# Install Squid proxy
./server/install.sh

# Start the proxy
./server/start.sh

# Enable exit node (for global mode)
./server/setup_exit_node.sh
```

After running `setup_exit_node.sh`, approve the exit node in the
[Tailscale admin console](https://login.tailscale.com/admin/machines).

### 2. Client (Your Mac in China)

```bash
# Run interactive setup
./client/setup.sh
```

This will:
1. Ask for your Canada Mac's Tailscale IP
2. Generate the PAC proxy file
3. Configure macOS auto-proxy settings
4. Install the `maple` command

## Usage

```bash
# Check status and connectivity
maple status

# Run full connectivity test
maple test

# Enable global mode (before interviews, API calls)
maple on

# Disable global mode
maple off

# View proxied domains
maple list

# Add/remove domains
maple add example.com
maple remove example.com
```

## Pre-configured Domains

The following domains are pre-configured for split routing:

| Category | Domains |
|----------|---------|
| Search & Email | google.com, gmail.com, youtube.com |
| AI Services | openai.com, claude.ai, anthropic.com |
| Video Conferencing | zoom.us, teams.microsoft.com, meet.google.com |
| Coding Platforms | hackerrank.com, coderpad.io, leetcode.com |
| Social | twitter.com, instagram.com, reddit.com |
| Development | github.com, stackoverflow.com, npmjs.com |

Edit `client/domains.txt` to customize, then run `maple list` to verify.

## When to Use Each Mode

| Scenario | Mode | Command |
|----------|------|---------|
| Browsing Google, YouTube | Split (default) | No action needed |
| Online interview (Zoom/Teams) | Global | `maple on` |
| Using OpenAI API | Global | `maple on` |
| Coding test (HackerRank) | Split (default) | No action needed |
| Done with interview | Back to split | `maple off` |

## Troubleshooting

**Proxy unreachable:**
1. Check Tailscale: `tailscale status`
2. Verify server Squid is running: SSH to Canada Mac, run `brew services list`
3. Run `maple test` for diagnosis

**Slow speeds:**
- Make sure you are in Split mode (not Global) for daily use
- Check Tailscale connection quality: `tailscale ping <server-ip>`

**Domain not proxied:**
- Add it: `maple add domain.com`
- Check `maple list` to verify

---

# Maple

通过加拿大 Mac 中转访问有地区限制的网站和服务。

## 工作原理

- **分流模式**（默认）：只有配置的域名走加拿大（浏览器）
- **全局模式**：所有流量走加拿大（Zoom/Teams/API 等桌面应用）

## 快速开始

1. 加拿大 Mac 上运行 `./server/install.sh` 和 `./server/start.sh`
2. 本地 Mac 上运行 `./client/setup.sh`
3. 用 `maple status` 检查连接状态

## 常用命令

| 命令 | 说明 |
|------|------|
| `maple on` | 开启全局模式（面试/API） |
| `maple off` | 关闭全局模式 |
| `maple status` | 查看状态 |
| `maple test` | 测试连通性 |
| `maple list` | 查看代理域名 |
| `maple add <domain>` | 添加域名 |
| `maple remove <domain>` | 删除域名 |
