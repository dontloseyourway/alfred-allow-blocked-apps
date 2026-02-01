# 更新日志

本项目的所有重要变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/),
本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/spec/v2.0.0.html)。

## [1.0.0] - 2026-02-01

### 首次发布 🎉

#### 功能特性
- 🎯 **Alfred 集成** - 直接在 Alfred 中操作，无需打开系统设置
- 🔍 **智能检测** - 读取 macOS Gatekeeper 数据库，只显示真正被系统拦截的应用
- 📱 **可视化图标** - 显示应用图标，方便识别
- ⚡ **极速解锁** - 3秒完成 vs 手动操作需要 30-60 秒
- 💫 **批量操作** - 一键解锁所有被阻止的应用
- ✅ **系统通知** - 即时反馈操作结果

#### 技术实现
- 扫描应用目录读取 `com.apple.quarantine` 扩展属性
- 使用 `xattr -rd com.apple.quarantine` 移除隔离属性
- 密码安全存储在 macOS 钥匙串，只需输入一次
- Alfred Script Filter 实现交互式应用选择
- 支持 macOS 10.15+ 和 Alfred 4+

[1.0.0]: https://github.com/dontloseyourway/alfred-allow-blocked-apps/releases/tag/v1.0.0
