//
//  Settings.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - General Settings
@Model
final class GeneralSettings {
    var startAtLaunch: Bool
    var showOnboarding: Bool
    var alertMinutesBefore: Int // Range: 0-60
    var enableSounds: Bool
    var selectedSound: String

    init() {
        self.startAtLaunch = true
        self.showOnboarding = true
        self.alertMinutesBefore = 5
        self.enableSounds = true
        self.selectedSound = "Default"
    }
}

// MARK: - Widget Settings
@Model
final class WidgetSettings {
    var displayMode: String // "alwaysOnDesktop", "menuBarOnly", "hidden"
    var size: String // "small", "medium", "large"
    var selectedMonitor: String // "main", "external1", "external2", "all"
    var positionX: Double
    var positionY: Double
    var audioHapticExperiences: Bool

    init() {
        self.displayMode = "alwaysOnDesktop"
        self.size = "medium"
        self.selectedMonitor = "main"
        self.positionX = 0
        self.positionY = 0
        self.audioHapticExperiences = true
    }

    var sizeValue: CGSize {
        switch size {
        case "small": return CGSize(width: 150, height: 100)
        case "large": return CGSize(width: 250, height: 200)
        default: return CGSize(width: 200, height: 150) // medium
        }
    }

    var position: CGPoint {
        CGPoint(x: positionX, y: positionY)
    }

    func setPosition(_ point: CGPoint) {
        positionX = point.x
        positionY = point.y
    }
}

// MARK: - Notification Settings
@Model
final class NotificationSettings {
    var style: String // "smallPopup", "fullScreenBlur"
    var autoCloseAfter10Seconds: Bool
    var playSound: Bool
    var selectedSound: String
    var enabledSnoozeDurations: [Int] // Array of minutes: [1, 5, 10, 15, 30]

    init() {
        self.style = "fullScreenBlur"
        self.autoCloseAfter10Seconds = false
        self.playSound = true
        self.selectedSound = "Alert"
        self.enabledSnoozeDurations = [1, 5, 10, 15, 30]
    }

    func isSnoozeDurationEnabled(_ minutes: Int) -> Bool {
        enabledSnoozeDurations.contains(minutes)
    }

    func toggleSnoozeDuration(_ minutes: Int) {
        if let index = enabledSnoozeDurations.firstIndex(of: minutes) {
            enabledSnoozeDurations.remove(at: index)
        } else {
            enabledSnoozeDurations.append(minutes)
            enabledSnoozeDurations.sort()
        }
    }
}

// MARK: - Sync Settings
@Model
final class SyncSettings {
    var selectedCalendars: [String] // Calendar identifiers
    var selectedReminderLists: [String] // List identifiers
    var syncTasksToReminders: Bool
    var syncMeetingsToCalendar: Bool
    var lastSyncDate: Date?

    init() {
        self.selectedCalendars = []
        self.selectedReminderLists = []
        self.syncTasksToReminders = true
        self.syncMeetingsToCalendar = true
        self.lastSyncDate = nil
    }

    func isCalendarSelected(_ identifier: String) -> Bool {
        selectedCalendars.contains(identifier)
    }

    func toggleCalendar(_ identifier: String) {
        if let index = selectedCalendars.firstIndex(of: identifier) {
            selectedCalendars.remove(at: index)
        } else {
            selectedCalendars.append(identifier)
        }
    }

    func isReminderListSelected(_ identifier: String) -> Bool {
        selectedReminderLists.contains(identifier)
    }

    func toggleReminderList(_ identifier: String) {
        if let index = selectedReminderLists.firstIndex(of: identifier) {
            selectedReminderLists.remove(at: index)
        } else {
            selectedReminderLists.append(identifier)
        }
    }
}

// MARK: - Focus Mode Settings
@Model
final class FocusModeSettings {
    var enabled: Bool
    var pauseNonUrgentAlerts: Bool
    var showVisualIndicator: Bool
    var ambientSound: String // "off", "ticking", "heartbeat", "binaural", "relaxBeat"
    var soundVolume: Float // 0.0 - 1.0

    init() {
        self.enabled = false
        self.pauseNonUrgentAlerts = true
        self.showVisualIndicator = true
        self.ambientSound = "off"
        self.soundVolume = 0.7
    }

    var ambientSoundFilename: String? {
        switch ambientSound {
        case "ticking": return "ticking.mp3"
        case "heartbeat": return "heartbeat.mp3"
        case "binaural": return "binaural.mp3"
        case "relaxBeat": return "relax.mp3"
        default: return nil
        }
    }
}

// MARK: - Shortcut Settings
struct KeyboardShortcutData: Codable {
    var key: String
    var modifiers: [String]

    static let quickCapture = KeyboardShortcutData(key: "l", modifiers: ["command"])
    static let showHideWidget = KeyboardShortcutData(key: "w", modifiers: ["command", "shift"])
    static let focusModeToggle = KeyboardShortcutData(key: "f", modifiers: ["command", "shift"])
    static let openIdeas = KeyboardShortcutData(key: "i", modifiers: ["command", "shift"])
    static let viewToday = KeyboardShortcutData(key: "t", modifiers: ["command", "shift"])
}

@Model
final class ShortcutSettings {
    var quickCaptureKey: String
    var quickCaptureModifiers: [String]
    var showHideWidgetKey: String
    var showHideWidgetModifiers: [String]
    var focusModeToggleKey: String
    var focusModeToggleModifiers: [String]
    var openIdeasKey: String
    var openIdeasModifiers: [String]
    var viewTodayKey: String
    var viewTodayModifiers: [String]

    init() {
        self.quickCaptureKey = "l"
        self.quickCaptureModifiers = ["command"]
        self.showHideWidgetKey = "w"
        self.showHideWidgetModifiers = ["command", "shift"]
        self.focusModeToggleKey = "f"
        self.focusModeToggleModifiers = ["command", "shift"]
        self.openIdeasKey = "i"
        self.openIdeasModifiers = ["command", "shift"]
        self.viewTodayKey = "t"
        self.viewTodayModifiers = ["command", "shift"]
    }
}

// MARK: - Appearance Settings
@Model
final class AppearanceSettings {
    var theme: String // "light", "dark", "auto"
    var alertBackgroundBlur: Float // 0.0 - 1.0
    var accentColorHex: String
    var fontSize: String // "small", "medium", "large"

    init() {
        self.theme = "auto"
        self.alertBackgroundBlur = 0.8
        self.accentColorHex = "#007AFF"
        self.fontSize = "medium"
    }

    var accentColor: Color {
        Color(hex: accentColorHex) ?? .blue
    }

    func setAccentColor(_ color: Color) {
        accentColorHex = color.toHex()
    }
}

// MARK: - AI Settings
@Model
final class AISettings {
    var apiKey: String // Store in Keychain in production
    var model: String
    var defaultTaskHour: Int // 0-23
    var defaultTaskMinute: Int // 0-59
    var autoCategorize: Bool
    var enhanceText: Bool
    var splitMultiTasks: Bool
    var useLocalProcessing: Bool
    var encryptCommunications: Bool

    init() {
        self.apiKey = ""
        self.model = "claude-sonnet-4-20250514"
        self.defaultTaskHour = 9
        self.defaultTaskMinute = 0
        self.autoCategorize = true
        self.enhanceText = true
        self.splitMultiTasks = true
        self.useLocalProcessing = false
        self.encryptCommunications = true
    }

    var defaultTaskTime: DateComponents {
        var components = DateComponents()
        components.hour = defaultTaskHour
        components.minute = defaultTaskMinute
        return components
    }
}

// MARK: - App Settings Container
@Model
final class AppSettings {
    var general: GeneralSettings?
    var widget: WidgetSettings?
    var notifications: NotificationSettings?
    var sync: SyncSettings?
    var focusMode: FocusModeSettings?
    var shortcuts: ShortcutSettings?
    var appearance: AppearanceSettings?
    var ai: AISettings?

    init() {
        self.general = GeneralSettings()
        self.widget = WidgetSettings()
        self.notifications = NotificationSettings()
        self.sync = SyncSettings()
        self.focusMode = FocusModeSettings()
        self.shortcuts = ShortcutSettings()
        self.appearance = AppearanceSettings()
        self.ai = AISettings()
    }
}
