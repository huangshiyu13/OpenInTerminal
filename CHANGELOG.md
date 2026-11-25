# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Fixed

## [2.3.10] - 2026-11-25

首个独立维护版本，重点修复 macOS 26/27（Tahoe / macOS 27.2.1）兼容性问题并适配 Xcode 27 编译。

### Added
- 新增支持 **Otty** 终端、**Glim** 编辑器以及 **Obsidian** 当前笔记目录/文件打开（需启用 Obsidian CLI）。
- 新增共享偏好设置回归测试套件 `Tests/SharedPreferences/run.sh`。
- 新增独立维护的 [CHANGELOG.md](./CHANGELOG.md) 与发版规范文档 [RELEASING.md](./RELEASING.md)。

### Changed
- 将各 Xcode target 的 `MACOSX_DEPLOYMENT_TARGET` 提升至 `12.0`，以支持 Xcode 27 编译。

### Fixed
- **macOS 26/27 偏好设置持久化与 Finder 扩展通信**：主程序改用自身标准 UserDefaults 域（`wang.jianing.app.OpenInTerminal`），并在 Finder 扩展的 `Application Scripts` 目录中原子写入 `0600` 权限的 `shared-settings.plist` 只读快照；解决在无付费开发者证书 / ad-hoc 签名下设置无法保存及 Finder 工具栏菜单为空的问题。
- **旧版 App Group 配置迁移**：支持从旧 `group.wang.jianing.app.OpenInTerminal` 容器一次性迁移配置；当 macOS 27 拒绝读取旧容器时记录首次启动临时默认值，若后续获得权限可读则自动恢复未修改的旧设置。
- **Finder 扩展监听与菜单兜底**：始终监控根目录 `/` 与已挂载卷，补充侧边栏右键菜单支持，缺少配置时兜底 `Terminal` / `TextEdit`，并移除主程序 `Info.plist` 中多余的 `NSExtension` 声明及无用的 App Group entitlements。
- **全局快捷键**：即使启动时未设置快捷键，也注册 `ShortcutRecorder` 动作，使得在偏好设置中新绑定的快捷键立即生效。
- **登录启动（Launch at Login）**：新增 `LaunchAtLoginManager`，在 macOS 13 及以上改用 `SMAppService.mainApp`（低版本保留 `SMLoginItemSetEnabled`），启动时自动迁移并停用旧版 `OpenInTerminalHelper` 登录项，同时修正 helper 中的主程序 Bundle ID。
- **工具栏图标与菜单图标**：修复 macOS 26.6+ / 27 下非活动 Finder 窗口的工具栏图标渲染异常（移除目标 Resources 中多余的 `AppIcon.icon` 引用），修正 `Hyper`、`Neovim`、`Otty` 菜单图标名称匹配及 `Obsidian` 图标尺寸。
- **已安装应用检测**：结合 LaunchServices 检测已安装应用，并跳过无权限或缺失目录的报错中断。

## [2.3.9] - 2026-07-13

- Fork 自上游 `Ji4n1ng/OpenInTerminal` `v2.3.9` 基线版本。更早版本的历史变更记录见 [README.md](./README.md#changes-)。

[Unreleased]: https://github.com/huangshiyu13/OpenInTerminal/compare/v2.3.10...HEAD
[2.3.10]: https://github.com/huangshiyu13/OpenInTerminal/compare/537ac2a...v2.3.10
[2.3.9]: https://github.com/Ji4n1ng/OpenInTerminal/releases/tag/v2.3.9
