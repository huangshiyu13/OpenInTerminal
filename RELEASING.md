# Release Guide (发版规范)

本文档定义 `huangshiyu13/OpenInTerminal` 独立维护期间的版本号管理、Changelog 维护、Git Tag 发版及本机更新流程。

## 1. 版本与分支约定

- **主分支**：`master`
- **版本号规则**：遵循语义化版本 `X.Y.Z`（沿用上游主程序 `2.3.x` 系列递增），正式版本必须打 **annotated git tag**：`vX.Y.Z`（例如 `v2.3.10`）。
- **当前发版范围约定**：每次正式发版**维护 `CHANGELOG.md` 并推送 `vX.Y.Z` tag**，不创建 GitHub Release 压缩包附件，也不向 Homebrew Cask 提交 PR。

## 2. 版本号存储位置

主程序（`OpenInTerminal`）：
- `OpenInTerminal.xcodeproj/project.pbxproj` 中以下 3 个 target 的 Debug / Release 配置，共 **6 处** `MARKETING_VERSION`：
  - `OpenInTerminal`
  - `OpenInTerminalFinderExtension`
  - `OpenInTerminalHelper`

> 注：`OpenInTerminalCore` 保持独立的框架版本号（当前为 `2.3.0`）；`OpenInTerminal-Lite` 与 `OpenInEditor-Lite` 分别维护在各自 `.xcodeproj/project.pbxproj` 中（当前为 `1.2.8`），如需同步发版时再一起更新。

## 3. 标准发版流程

### 第一步：更新 Changelog 与版本号

1. 检查自上一个 tag 以来的提交记录：
   ```bash
   git log --oneline $(git describe --tags --abbrev=0)..HEAD
   ```
2. 编辑 [CHANGELOG.md](./CHANGELOG.md)：
   - 将 `## [Unreleased]` 下的条目归档到新的 `## [X.Y.Z] - YYYY-MM-DD` 章节（按 `Added` / `Changed` / `Fixed` 分类）。
   - 重新保留一个空的 `## [Unreleased]` 章节，并更新文末的对比链接 `[Unreleased]` 与 `[X.Y.Z]`。
3. 更新 `OpenInTerminal.xcodeproj/project.pbxproj` 中的 6 处 `MARKETING_VERSION` 为 `X.Y.Z`，并确认无遗漏：
   ```bash
   grep -n "MARKETING_VERSION" OpenInTerminal.xcodeproj/project.pbxproj
   ```

### 第二步：测试与本地构建验证

1. 运行偏好设置回归测试：
   ```bash
   bash Tests/SharedPreferences/run.sh
   ```
   确认输出两行 `PASS:` 且退出码为 `0`。
2. 执行本地构建（无付费开发者证书时使用 ad-hoc 签名）：
   ```bash
   ./build-unsigned.sh
   ```
3. 核对构建产物版本号与签名完整性：
   ```bash
   defaults read "$PWD/export/OpenInTerminal.app/Contents/Info.plist" CFBundleShortVersionString
   defaults read "$PWD/export/OpenInTerminal.app/Contents/PlugIns/OpenInTerminalFinderExtension.appex/Contents/Info.plist" CFBundleShortVersionString
   codesign --verify --deep --strict export/OpenInTerminal.app
   ```

### 第三步：提交、打 Tag 并推送

```bash
git add -A
git commit -m "chore(release): vX.Y.Z"
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin master
git push origin vX.Y.Z
```

验证远端 tag：
```bash
git ls-remote --tags origin vX.Y.Z
```

### 第四步：更新本机安装的 App（可选，推荐）

为避免 macOS LaunchServices / `pluginkit` 误绑定到仓库内的 `build/` 或 `export/` 目录，务必在注册扩展前删除临时构建产物：

```bash
killall OpenInTerminal OpenInTerminalHelper OpenInTerminalFinderExtension 2>/dev/null || true
sleep 1

rm -rf /Applications/OpenInTerminal.app
ditto --norsrc --noextattr export/OpenInTerminal.app /Applications/OpenInTerminal.app
xattr -dr com.apple.quarantine /Applications/OpenInTerminal.app 2>/dev/null || true
codesign --verify --deep --strict /Applications/OpenInTerminal.app

# 清理仓库内的临时构建产物，防止 pluginkit 绑定到非 /Applications 路径
rm -rf build export

/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/OpenInTerminal.app
pluginkit -a /Applications/OpenInTerminal.app/Contents/PlugIns/OpenInTerminalFinderExtension.appex
pluginkit -e use -i wang.jianing.app.OpenInTerminal.OpenInTerminalFinderExtension

open -a /Applications/OpenInTerminal.app
sleep 2
killall Finder
```

安装完成后可通过以下命令确认运行状态：
- `defaults read /Applications/OpenInTerminal.app/Contents/Info.plist CFBundleShortVersionString`
- `pluginkit -m -v -i wang.jianing.app.OpenInTerminal.OpenInTerminalFinderExtension`
- `tail -n 20 ~/Library/Logs/OpenInTerminal/OpenInTerminal-0.log`

> 注意：不要使用 `brew upgrade --cask openinterminal` 更新本地自建版本，否则会被上游旧版覆盖。
