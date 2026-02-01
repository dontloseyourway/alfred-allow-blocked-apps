<div align="center">

# 🚀 Allow Blocked Apps

### 通过 Alfred 快速解除 macOS 应用的安全拦截

[![GitHub release](https://img.shields.io/github/release/dontloseyourway/alfred-allow-blocked-apps.svg)](https://github.com/dontloseyourway/alfred-allow-blocked-apps/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-10.15+-blue.svg)](https://www.apple.com/macos/)
[![Alfred](https://img.shields.io/badge/Alfred-4.0+-purple.svg)](https://www.alfredapp.com/)

**告别繁琐的系统设置操作!**

[功能特性](#-功能特性) • [安装说明](#-安装说明) • [使用方法](#-使用方法) • [常见问题](#-常见问题)

</div>

---

## ✨ 功能特性

- 🎯 **Alfred 集成** - 直接在 Alfred 中操作，无需打开系统设置
- 🔍 **智能检测** - 只显示真正被系统拦截的应用
- 📱 **可视化图标** - 显示应用图标，方便识别  
- ⚡ **极速解锁** - 3秒完成 vs 手动操作需要 30-60 秒
- 💫 **批量操作** - 一键解锁所有被阻止的应用
- ✅ **系统通知** - 即时反馈操作结果

---

## 📦 安装说明

### 方法一: 下载发布版本 (推荐)

1. 从 [Releases](https://github.com/dontloseyourway/alfred-allow-blocked-apps/releases) 下载最新的 `Allow-Blocked-Apps.alfredworkflow`
2. 双击文件进行安装
3. Alfred 会自动导入该工作流

### 方法二: 从源码构建

```bash
# 克隆仓库
git clone https://github.com/dontloseyourway/alfred-allow-blocked-apps.git
cd alfred-allow-blocked-apps

# 构建工作流
python3 build.py

# 安装
open Allow-Blocked-Apps.alfredworkflow
```

### 系统要求

- macOS 10.15 (Catalina) 或更高版本
- [Alfred 4](https://www.alfredapp.com/) 或更高版本 (需要 Powerpack)
- Python 3 (仅从源码构建时需要)

---

## 🎯 使用方法

1. 按下 Alfred 快捷键 (默认: `⌥ + Space`)
2. 输入 `allow`
3. 从列表中选择被系统拦截的应用
4. 按 `Enter` 确认并输入密码
5. 完成! 应用已解锁

### 批量解锁

选择 **"🎯 允许所有被拦截的应用"** 即可一次性解锁所有检测到的应用。

---

## ⚡ 性能对比

| 方法 | 步骤数 | 耗时 | 是否打断工作流 |
|------|--------|------|----------------|
| **手动 (系统设置)** | 6步 | 30-60秒 | 是 |
| **本工作流** | 2步 | 3秒 | 否 |

**快 10 倍!** ⚡

---

## 🛠️ 工作原理

macOS Gatekeeper 会为下载的应用添加 `com.apple.quarantine` 扩展属性。本工作流：

1. 扫描多个常见位置的应用 (`/Applications`、`~/Applications`、`~/Downloads`、`~/Desktop` 等)
2. 读取应用的 `com.apple.quarantine` 扩展属性
3. 根据隔离标志位判断是否真正被拦截
4. 使用 `xattr -rd com.apple.quarantine` 移除隔离属性

---

## ❓ 常见问题

**问: 需要 Alfred Powerpack 吗?**  
答: 是的，工作流功能需要 Alfred Powerpack (付费版本)。

**问: 这安全吗?**  
答: 完全安全。它使用苹果官方的 `xattr` 命令。代码开源可供审查。

**问: 为什么需要 sudo?**  
答: 移除扩展属性需要管理员权限。密码会安全存储在 macOS 钥匙串中，只需输入一次。

**问: 可以撤销吗?**  
答: 一旦解锁，文件就能正常运行。无法通过本工具重新拦截。

---

## 🤝 参与贡献

欢迎贡献! 请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解贡献指南。

---

## 📝 更新日志

查看 [CHANGELOG.md](CHANGELOG.md) 了解版本历史。

---

## 📄 开源协议

本项目采用 MIT 协议 - 详见 [LICENSE](LICENSE) 文件。

---

<div align="center">

如果觉得这个项目有用，请考虑给个 Star ⭐

**[⬆ 返回顶部](#-allow-blocked-apps)**

</div>
