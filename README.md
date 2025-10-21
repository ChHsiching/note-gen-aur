# NoteGen AUR 包维护仓库

这是 [NoteGen](https://github.com/codexu/note-gen) 的 Arch Linux AUR 包的自动化维护仓库。

[English](README_EN.md) | 简体中文

## 🔧 自动化功能

- ✅ **版本监控**: 每小时自动检查上游新版本
- ✅ **自动构建**: 发现新版本时自动构建和测试
- ✅ **PKGBUILD更新**: 自动更新版本号和校验和
- ✅ **AUR部署**: 自动提交更新到 AUR 仓库
- ✅ **错误通知**: 构建失败时提供详细错误信息

## 📦 安装

从 AUR 安装（推荐）：

```bash
paru -S note-gen
# 或
yay -S note-gen
```

## 🚀 自动化工作流

### 1. 版本监控 (`check-upstream.yml`)
- 每小时检查 GitHub Releases
- 比较当前版本与最新版本
- 发现更新时触发构建流程

### 2. 自动更新 (`update-aur.yml`)
- 更新 PKGBUILD 版本号
- 下载源码并生成校验和
- 构建包进行验证
- 生成新的 .SRCINFO
- 提交变更到仓库

### 3. AUR部署 (`deploy-aur.yml`)
- PKGBUILD 或 .SRCINFO 变更时触发
- 验证包构建
- 自动部署到 AUR 仓库

## 🛠️ 手动维护

### 本地构建测试

```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/note-gen-aur.git
cd note-gen-aur

# 下载源码
makepkg -f

# 安装
sudo pacman -U note-gen-*.pkg.tar.zst
```

### 手动更新版本

```bash
# 更新版本号
sed -i 's/^pkgver=.*/pkgver=NEW_VERSION/' PKGBUILD
sed -i 's/^pkgrel=.*/pkgrel=1/' PKGBUILD

# 生成校验和
makepkg -g

# 更新校验和到 PKGBUILD
makepkg --geninteg

# 生成 .SRCINFO
makepkg --printsrcinfo > .SRCINFO

# 提交变更
git add PKGBUILD .SRCINFO
git commit -m "Update to NEW_VERSION"
git push
```

## 🔑 配置要求

### GitHub Secrets

为了启用完整的自动化功能，需要在仓库设置中配置以下 Secrets：

- `AUR_SSH_KEY`: AUR 仓库的 SSH 私钥

### AUR 设置

1. 创建 AUR SSH 密钥对：
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/aur_key
   ```

2. 添加公钥到 AUR：
   - 复制 `aur_key.pub` 内容到 AUR 账户的 SSH 密钥设置中

3. 添加私钥到 GitHub Secrets：
   - 复制 `aur_key` 内容作为 `AUR_SSH_KEY` Secret

## 🆘 故障排除

### 构建失败

1. 检查依赖项是否完整
2. 验证 Rust 工具链版本
3. 检查 Node.js 和 pnpm 版本
4. 查看构建日志中的详细错误

### AUR 提交失败

1. 验证 SSH 密钥配置
2. 检查 AUR 包名称冲突
3. 确认 PKGBUILD 语法正确
4. 验证 .SRCINFO 格式

### 版本检测问题

1. 检查上游 GitHub API 可访问性
2. 验证版本号格式解析
3. 手动检查版本号比较逻辑

## 📋 维护检查清单

定期检查以下项目：

- [ ] 自动化工作流正常运行
- [ ] AUR 包没有用户投诉
- [ ] 构建依赖项保持更新
- [ ] 安全漏洞扫描
- [ ] 版本监控及时准确

## 🤝 贡献

发现问题或改进建议？欢迎提交 Issue 或 Pull Request！

### 紧急处理

如果自动化流程失败，可以：

1. 手动执行更新流程
2. 检查 GitHub Actions 日志
3. 在 AUR 页面回复用户反馈
4. 必要时手动回滚到稳定版本

## 📄 许可证

本维护仓库遵循 MIT 许可证。NoteGen 软件本身受其原始许可证约束。