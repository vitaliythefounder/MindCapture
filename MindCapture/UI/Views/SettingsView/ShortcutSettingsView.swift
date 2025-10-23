//
//  ShortcutSettingsView.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import SwiftUI

struct ShortcutSettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var settings: ShortcutSettings?

    var body: some View {
        Form {
            Section("Keyboard Shortcuts") {
                ShortcutRow(
                    title: "Quick Capture",
                    key: Binding(get: { settings?.quickCaptureKey ?? "l" }, set: { settings?.quickCaptureKey = $0; saveSettings() }),
                    modifiers: Binding(get: { settings?.quickCaptureModifiers ?? ["command"] }, set: { settings?.quickCaptureModifiers = $0; saveSettings() })
                )

                ShortcutRow(
                    title: "Show/Hide Widget",
                    key: Binding(get: { settings?.showHideWidgetKey ?? "w" }, set: { settings?.showHideWidgetKey = $0; saveSettings() }),
                    modifiers: Binding(get: { settings?.showHideWidgetModifiers ?? ["command", "shift"] }, set: { settings?.showHideWidgetModifiers = $0; saveSettings() })
                )

                ShortcutRow(
                    title: "Focus Mode Toggle",
                    key: Binding(get: { settings?.focusModeToggleKey ?? "f" }, set: { settings?.focusModeToggleKey = $0; saveSettings() }),
                    modifiers: Binding(get: { settings?.focusModeToggleModifiers ?? ["command", "shift"] }, set: { settings?.focusModeToggleModifiers = $0; saveSettings() })
                )

                ShortcutRow(
                    title: "Open Ideas Vault",
                    key: Binding(get: { settings?.openIdeasKey ?? "i" }, set: { settings?.openIdeasKey = $0; saveSettings() }),
                    modifiers: Binding(get: { settings?.openIdeasModifiers ?? ["command", "shift"] }, set: { settings?.openIdeasModifiers = $0; saveSettings() })
                )

                ShortcutRow(
                    title: "View Today's Tasks",
                    key: Binding(get: { settings?.viewTodayKey ?? "t" }, set: { settings?.viewTodayKey = $0; saveSettings() }),
                    modifiers: Binding(get: { settings?.viewTodayModifiers ?? ["command", "shift"] }, set: { settings?.viewTodayModifiers = $0; saveSettings() })
                )
            }

            Section {
                Button("Reset to Defaults") {
                    resetToDefaults()
                }
                .foregroundColor(.red)

                Text("Click the shortcut field and press your desired key combination")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Shortcuts")
        .onAppear {
            loadSettings()
        }
    }

    private func loadSettings() {
        if let appSettings = dataManager.fetchSettings() {
            settings = appSettings.shortcuts
        }
    }

    private func saveSettings() {
        dataManager.updateSettings(dataManager.fetchSettings()!)
    }

    private func resetToDefaults() {
        settings?.quickCaptureKey = "l"
        settings?.quickCaptureModifiers = ["command"]
        settings?.showHideWidgetKey = "w"
        settings?.showHideWidgetModifiers = ["command", "shift"]
        settings?.focusModeToggleKey = "f"
        settings?.focusModeToggleModifiers = ["command", "shift"]
        settings?.openIdeasKey = "i"
        settings?.openIdeasModifiers = ["command", "shift"]
        settings?.viewTodayKey = "t"
        settings?.viewTodayModifiers = ["command", "shift"]
        saveSettings()
    }
}

struct ShortcutRow: View {
    let title: String
    @Binding var key: String
    @Binding var modifiers: [String]

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(shortcutText)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(4)
        }
    }

    private var shortcutText: String {
        var parts: [String] = []
        if modifiers.contains("command") { parts.append("⌘") }
        if modifiers.contains("shift") { parts.append("⇧") }
        if modifiers.contains("option") { parts.append("⌥") }
        if modifiers.contains("control") { parts.append("⌃") }
        parts.append(key.uppercased())
        return parts.joined()
    }
}

#Preview {
    ShortcutSettingsView()
        .environmentObject(DataManager.shared)
}
