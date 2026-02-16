# Maple 使用指南

Maple 通过 [Tailscale](https://tailscale.com) 隧道和 [Squid](http://www.squid-cache.org/) 代理，将你的网络流量转发到远程服务器。提供三种路由模式和简单的命令行工具。

## 架构

```
客户端  ----Tailscale----->  服务端  ----->  互联网
  |                            |
  |-- PAC 分流（浏览器）        |-- Squid 代理 (:3128)
  |-- 全局模式（所有应用）      |-- Tailscale Exit Node
```

- **全局模式**（global）：所有应用的所有流量通过服务端转发（使用 Tailscale 出口节点）
- **分流模式**（split，默认）：只有 domains.txt 配置的域名通过服务端转发（浏览器通过本地 HTTP 服务器读取 PAC 文件）
- **关闭**（off）：禁用所有代理，所有流量直连

## 前置要求

两台机器都需要：
- macOS
- 安装并连接 [Tailscale](https://tailscale.com/download)
- 安装 [Homebrew](https://brew.sh)
- Python 3 (macOS 内置)

## 安装

### 服务端

服务端是用来中转流量的远程机器。

```bash
# 安装 Squid 代理
./server/install.sh

# 启动代理
./server/start.sh

# 启用出口节点（全局模式需要）
./server/setup_exit_node.sh
```

运行 `setup_exit_node.sh` 后，需要在 [Tailscale 管理后台](https://login.tailscale.com/admin/machines) 批准出口节点。

### 客户端

客户端是你本地使用的机器。

```bash
# 运行交互式安装
./client/setup.sh
```

安装过程会：
1. 询问服务端的 Tailscale IP
2. 生成 PAC 代理文件
3. 配置 macOS 自动代理设置
4. 安装 `maple` 命令

## 命令一览

### 状态与诊断

| 命令 | 说明 |
|------|------|
| `maple status` | 查看当前模式、连通性和延迟 |
| `maple test` | 运行完整连通性测试 |
| `maple ping` | 测量到服务端的延迟（Tailscale + ICMP） |
| `maple speed` | 测量代理下载速度 vs 直连速度 |

### 模式切换

| 命令 | 说明 |
|------|------|
| `maple global` | 开启全局模式（所有流量走服务端） |
| `maple split` | 开启分流模式（只有 domains.txt 走代理） |
| `maple off` | 关闭代理（禁用 exit node + 禁用 PAC，所有流量直连） |

### 域名管理

| 命令 | 说明 |
|------|------|
| `maple list` | 查看所有代理域名 |
| `maple add <域名>` | 添加域名到代理列表 |
| `maple remove <域名>` | 从代理列表移除域名 |

### 其他

| 命令 | 说明 |
|------|------|
| `maple setup` | 重新运行初始设置 |
| `maple help` | 显示帮助 |

## 使用场景

| 场景 | 模式 | 操作 |
|------|------|------|
| 浏览代理域名（Google、YouTube 等） | split（默认） | 无需操作 |
| 视频会议（Zoom/Teams/Meet） | global | 会前运行 `maple global` |
| 使用外部 API（OpenAI 等） | global | `maple global` |
| 在线笔试（HackerRank、CoderPad） | split（默认） | 无需操作 |
| 会议/面试结束 | split | `maple split` |
| 完全不需要代理 | off | `maple off` |

## 域名管理

域名保存在 `client/domains.txt`，每行一个域名，用 `# === 分类名 ===` 作为分组注释。

```bash
# 添加域名
maple add netflix.com

# 删除域名
maple remove netflix.com

# 查看列表
maple list
```

也可以直接编辑 `client/domains.txt`，然后重新生成 PAC 文件：

```bash
bash client/generate_pac.sh
```

## 网络诊断

### 延迟测试

```bash
maple ping
```

显示内容：
- **Tailscale ping**：测量 Tailscale 隧道延迟（DERP 中继 vs 直连）
- **ICMP ping**：传统 5 包 ping，显示 min/avg/max 统计

### 网速测试

```bash
maple speed
```

分别通过代理和直连下载测试文件，显示：
- 1 MB 和 10 MB 代理下载速度（Mbps）
- 1 MB 直连下载速度作为对比

### 快速查看

```bash
maple status
```

一次性显示模式、连通性、延迟和域名数量。延迟值按颜色标识：
- **绿色**：< 100 ms
- **黄色**：100-250 ms
- **红色**：> 250 ms

## 故障排查

**代理无法连接：**
1. 检查 Tailscale：`tailscale status`
2. 确认服务端 Squid 在运行：`brew services list`
3. 运行 `maple test` 逐步诊断

**速度慢：**
- 日常浏览用分流模式，不要开全局
- 运行 `maple speed` 检查实际带宽
- 运行 `maple ping` 检查延迟

**域名未被代理：**
- 添加：`maple add domain.com`
- 确认：`maple list`

**全局模式不工作：**
- 确认出口节点已在 [Tailscale 管理后台](https://login.tailscale.com/admin/machines) 批准
- 运行 `maple test` 检查连通性

**关闭模式后仍有代理：**
- 运行 `maple status` 确认模式为 OFF
- 检查浏览器是否有独立的代理设置
