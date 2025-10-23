//
//  Constants.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import Foundation
import SwiftUI

struct Constants {
    // MARK: - App Info
    static let appName = "MindCapture"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"

    // MARK: - Widget Sizes
    enum WidgetSize {
        case small, medium, large

        var size: CGSize {
            switch self {
            case .small: return CGSize(width: 150, height: 100)
            case .medium: return CGSize(width: 200, height: 150)
            case .large: return CGSize(width: 250, height: 200)
            }
        }

        var name: String {
            switch self {
            case .small: return "Small"
            case .medium: return "Medium"
            case .large: return "Large"
            }
        }
    }

    // MARK: - Snooze Durations (in minutes)
    static let snoozeDurations = [1, 5, 10, 15, 30]

    // MARK: - Alert Timing Range
    static let minAlertMinutes = 0
    static let maxAlertMinutes = 60
    static let defaultAlertMinutes = 5

    // MARK: - Sound Names
    static let alertSounds = ["Default", "Ping", "Glass", "Boop", "Chime"]
    static let ambientSounds = ["Off", "Ticking", "Heartbeat", "Binaural", "Relax Beat"]

    // MARK: - Ambient Sound Files
    static let ambientSoundFiles: [String: String] = [
        "Ticking": "ticking.mp3",
        "Heartbeat": "heartbeat.mp3",
        "Binaural": "binaural.mp3",
        "Relax Beat": "relax.mp3"
    ]

    // MARK: - Theme Options
    static let themes = ["Light", "Dark", "Auto"]

    // MARK: - Font Size Options
    static let fontSizes = ["Small", "Medium", "Large"]

    // MARK: - Display Modes
    static let displayModes = ["Always On Desktop", "Menu Bar Only", "Hidden"]

    // MARK: - Notification Styles
    static let notificationStyles = ["Small Popup", "Full-Screen Blur"]

    // MARK: - API Configuration
    static let claudeAPIEndpoint = "https://api.anthropic.com/v1/messages"
    static let defaultClaudeModel = "claude-sonnet-4-20250514"
    static let apiVersion = "2023-06-01"

    // MARK: - Auto-close Timer
    static let autoCloseSeconds = 10.0

    // MARK: - Widget Update Interval
    static let widgetUpdateInterval: TimeInterval = 1.0 // Update every second

    // MARK: - Quick Capture Window Size
    static let quickCaptureWindowSize = CGSize(width: 500, height: 200)

    // MARK: - Glassmorphism Effect
    static let glassBlurRadius: CGFloat = 20.0
    static let glassOpacity: Double = 0.3

    // MARK: - Animation Durations
    static let shortAnimationDuration: Double = 0.2
    static let mediumAnimationDuration: Double = 0.3
    static let longAnimationDuration: Double = 0.5

    // MARK: - UserDefaults Keys
    enum UserDefaultsKey {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let apiKeyStoredInKeychain = "apiKeyStoredInKeychain"
        static let widgetPosition = "widgetPosition"
        static let selectedMonitor = "selectedMonitor"
    }

    // MARK: - Keychain Keys
    enum KeychainKey {
        static let claudeAPIKey = "com.vitaliy.MindCapture.claudeAPIKey"
    }

    // MARK: - Notification Identifiers
    enum NotificationIdentifier {
        static let taskAlert = "com.vitaliy.MindCapture.taskAlert"
        static let meetingAlert = "com.vitaliy.MindCapture.meetingAlert"
    }

    // MARK: - Calendar & Reminders
    static let calendarSyncInterval: TimeInterval = 300 // 5 minutes
    static let remindersSyncInterval: TimeInterval = 300 // 5 minutes

    // MARK: - Focus Mode
    static let defaultFocusModeVolume: Float = 0.7
    static let volumeRange: ClosedRange<Float> = 0.0...1.0

    // MARK: - History & Statistics
    static let maxHistoryItems = 1000
    static let statisticsDateRange = 30 // days

    // MARK: - Ideas Vault
    static let maxTagsPerIdea = 10
    static let maxImagesPerIdea = 5

    // MARK: - Task Limits
    static let maxTitleLength = 200
    static let maxNotesLength = 5000

    // MARK: - Colors
    enum AppColor {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        #if os(macOS)
        static let background = Color(NSColor.windowBackgroundColor)
        #else
        static let background = Color(.systemBackground)
        #endif
    }
}
