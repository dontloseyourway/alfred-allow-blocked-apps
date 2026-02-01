# 参与贡献

感谢你对本项目的关注! 🎉

## 如何贡献

### 报告问题

如果你发现了 bug,请创建 issue 并包含:
- macOS 版本
- Alfred 版本
- 复现步骤
- 期望行为 vs 实际行为

### 功能建议

欢迎提出功能需求! 请:
- 先检查现有的 issues
- 描述使用场景
- 解释为什么这个功能有用

### Pull Requests

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 进行修改
4. 在 macOS 上充分测试
5. 提交清晰的 commit 信息
6. 推送到你的 fork
7. 创建 Pull Request

### 开发环境搭建

```bash
# 克隆仓库
git clone https://github.com/dontloseyourway/alfred-allow-blocked-apps.git
cd alfred-allow-blocked-apps

# 修改 src/ 目录中的脚本
vim src/alfred_list.sh

# 重新构建工作流
python3 build.py

# 测试工作流
open Allow-Blocked-Apps.alfredworkflow
```

### 代码规范

- 使用 shellcheck 检查 bash 脚本
- 遵循现有代码风格
- 为复杂逻辑添加注释
- 保持函数简洁专注

### 测试

提交前请确保:
- 如果可能,在纯净的 macOS 安装环境中测试
- 验证工作流可以正确导入
- 测试多个被拦截的应用
- 检查系统通知是否正常工作

## 有问题?

欢迎随时创建 issue 提问!

---

感谢你的贡献! 🚀