//
//  Config.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/20.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import Foundation
import OpenInTerminalCore
import ServiceManagement

struct Constants {
    
    struct Id {
        static let LauncherApp = "wang.jianing.app.OpenInTerminalHelper"
        static let FinderExtension = "wang.jianing.app.OpenInTerminal.OpenInTerminalFinderExtension"
        static let CustomAppCell = NSUserInterfaceItemIdentifier(rawValue: "customAppCell")
        static let CustomMenuCell = NSUserInterfaceItemIdentifier(rawValue: "customMenuCell")
        static let CustomInputViewController = "CustomInputViewController"
    }
    
    static let none = "None"
    
    struct Key {
        static let defaultTerminalShortcut = "OIT_DefaultTerminalShortcut"
        static let defaultEditorShortcut = "OIT_DefaultEditorShortcut"
        static let copyPathShortcut = "OIT_CopyPathShortcut"
        static let onlyActivateShortcutsInFinder = "OnlyActivateShortcutsInFinder"
    }
    
    static let PreferencesStoryboard = NSStoryboard(name: "Preferences", bundle: nil)
}

enum LaunchAtLoginManager {
    static var isEnabledOrAwaitingApproval: Bool {
        if #available(macOS 13.0, *) {
            let mainStatus = SMAppService.mainApp.status
            if mainStatus == .enabled || mainStatus == .requiresApproval {
                return true
            }
            let legacyStatus = SMAppService.loginItem(identifier: Constants.Id.LauncherApp).status
            return legacyStatus == .enabled || legacyStatus == .requiresApproval
        }

        // The legacy API does not expose registration status. The saved value
        // remains the source of truth on macOS 12 and earlier.
        return DefaultsManager.shared.isLaunchAtLogin
    }

    /// Applies a user-requested login-item state and returns the state that the
    /// preferences UI should display.
    @discardableResult
    static func setEnabled(_ enabled: Bool, openSettingsIfApprovalIsRequired: Bool = true) -> Bool {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            let legacyHelper = SMAppService.loginItem(identifier: Constants.Id.LauncherApp)

            do {
                if enabled {
                    switch service.status {
                    case .enabled, .requiresApproval:
                        break
                    case .notRegistered, .notFound:
                        try service.register()
                    @unknown default:
                        try service.register()
                    }
                } else if service.status != .notRegistered {
                    try service.unregister()
                }
            } catch {
                logw("Unable to \(enabled ? "register" : "unregister") launch at login: \(error.localizedDescription)")
            }

            let isMainEnabled = service.status == .enabled || service.status == .requiresApproval
            if (!enabled || isMainEnabled),
               legacyHelper.status == .enabled || legacyHelper.status == .requiresApproval {
                do {
                    try legacyHelper.unregister()
                } catch {
                    logw("Unable to unregister legacy launch-at-login helper: \(error.localizedDescription)")
                }
            }

            if enabled && service.status == .requiresApproval {
                logw("Launch at login requires approval in System Settings")
                if openSettingsIfApprovalIsRequired {
                    SMAppService.openSystemSettingsLoginItems()
                }
            }

            return isEnabledOrAwaitingApproval
        }

        let succeeded = SMLoginItemSetEnabled(Constants.Id.LauncherApp as CFString, enabled)
        if !succeeded {
            logw("Unable to \(enabled ? "enable" : "disable") the legacy launch-at-login helper")
        }
        return succeeded ? enabled : DefaultsManager.shared.isLaunchAtLogin
    }

    /// Upgrades a previously saved or legacy-helper launch-at-login setting
    /// to SMAppService.mainApp without repeatedly registering an already-known service.
    static func reconcileSavedPreference() {
        let shouldEnable: Bool
        if #available(macOS 13.0, *) {
            let legacyStatus = SMAppService.loginItem(identifier: Constants.Id.LauncherApp).status
            let legacyActive = legacyStatus == .enabled || legacyStatus == .requiresApproval
            shouldEnable = DefaultsManager.shared.isLaunchAtLogin || legacyActive
        } else {
            shouldEnable = DefaultsManager.shared.isLaunchAtLogin
        }
        guard shouldEnable else { return }
        let actualState = setEnabled(true, openSettingsIfApprovalIsRequired: false)
        if DefaultsManager.shared.isLaunchAtLogin != actualState {
            DefaultsManager.shared.isLaunchAtLogin = actualState
        }
    }
}

extension NSImage {
    
    enum AssetIdentifier: String {
        case StatusBarIcon
    }
    
    convenience init(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)!
    }
}

extension NSStoryboard {
    
    enum StoryboardIdentifier: String {
        case Preferences
    }
    
    convenience init(storyboardIdentifier: StoryboardIdentifier) {
        self.init(name: storyboardIdentifier.rawValue, bundle: nil)
    }
}
