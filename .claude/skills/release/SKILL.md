---
name: release
description: Release a new version of huangshiyu13/OpenInTerminal — update CHANGELOG.md, bump MARKETING_VERSION, run tests and build-unsigned.sh, commit, push an annotated git tag (vX.Y.Z), and optionally update /Applications/OpenInTerminal.app. Use when the user wants to "release", "publish a new version", "ship", or tag a new release.
---

# Release Process for huangshiyu13/OpenInTerminal

This fork maintains its own changelog and git-tag releases (no GitHub Release binary attachments and no Homebrew Cask PRs unless explicitly requested).

Follow [RELEASING.md](../../../RELEASING.md) as the source of truth:

1. **Determine version `X.Y.Z`**:
   - Increment from the latest `v*` tag (main app series `v2.3.x`), or confirm with the user.
   - Check `git ls-remote --tags origin vX.Y.Z` is empty.
2. **Update `CHANGELOG.md`**:
   - Move items from `## [Unreleased]` into `## [X.Y.Z] - YYYY-MM-DD`, keeping an empty `## [Unreleased]` section and updating the compare links at the bottom.
3. **Bump `MARKETING_VERSION`**:
   - Update all 6 `MARKETING_VERSION` entries (Debug + Release for `OpenInTerminal`, `OpenInTerminalFinderExtension`, `OpenInTerminalHelper`) in `OpenInTerminal.xcodeproj/project.pbxproj`.
   - Verify with `grep -n "MARKETING_VERSION" OpenInTerminal.xcodeproj/project.pbxproj`.
4. **Test and build**:
   - Run `bash Tests/SharedPreferences/run.sh` (all `PASS`).
   - Run `./build-unsigned.sh` and verify `CFBundleShortVersionString` in `export/OpenInTerminal.app` and `codesign --verify --deep --strict export/OpenInTerminal.app`.
5. **Commit, tag, and push**:
   - `git commit -m "chore(release): vX.Y.Z"`
   - `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
   - `git push origin master && git push origin vX.Y.Z`
6. **Update `/Applications/OpenInTerminal.app` (when requested or on dev Mac)**:
   - Quit running `OpenInTerminal`, `OpenInTerminalHelper`, `OpenInTerminalFinderExtension`.
   - Replace `/Applications/OpenInTerminal.app` with `ditto --norsrc --noextattr export/OpenInTerminal.app /Applications/OpenInTerminal.app`, remove quarantine, verify `codesign`.
   - Remove `build/` and `export/` **before** running `lsregister -f` and `pluginkit -a` / `pluginkit -e use` so Finder never binds to a build directory inside the repo.
   - Launch `/Applications/OpenInTerminal.app`, restart Finder (`killall Finder`), and verify version in `pluginkit -m -v` and `~/Library/Logs/OpenInTerminal/OpenInTerminal-0.log`.
