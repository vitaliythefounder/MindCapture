//
//  SettingsView.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var claudeClient: ClaudeClient
    @State private var selectedTab: SettingsTab = .general

    enum SettingsTab: String, CaseIterable, Identifiable {
        case general = "General"
        case widget = "Widget"
        case notifications = "Notifications"
        case calendars = "Calendars & Reminders"
        case focus = "Focus Mode"
        case shortcuts = "Shortcuts"
        case appearance = "Appearance"
        case ai = "AI"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .general: return "gear"
            case .widget: return "rectangle.on.rectangle.angled"
            case .notifications: return "bell.fill"
            case .calendars: return "calendar"
            case .focus: return "moon.fill"
            case .shortcuts: return "command"
            case .appearance: return "paintbrush.fill"
            case .ai: return "brain.head.profile"
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            List(SettingsTab.allCases, selection: $selectedTab) { tab in
                Label(tab.rawValue, systemImage: tab.icon)
                    .tag(tab)
            }
            .navigationTitle("Settings")
            .frame(minWidth: 200)
        } detail: {
            Group {
                switch selectedTab {
                case .general:
                    GeneralSettingsView()
                case .widget:
                    WidgetSettingsView()
                case .notifications:
                    NotificationSettingsView()
                case .calendars:
                    CalendarSettingsView()
                case .focus:
                    FocusModeSettingsView()
                case .shortcuts:
                    ShortcutSettingsView()
                case .appearance:
                    AppearanceSettingsView()
                case .ai:
                    AISettingsView()
                }
            }
            .frame(minWidth: 500, minHeight: 400)
            .padding()
        }
        .frame(minWidth: 700, minHeight: 500)
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataManager.shared)
        .environmentObject(ClaudeClient())
}
