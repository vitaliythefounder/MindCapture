//
//  NotificationSettingsView.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import SwiftUI

struct NotificationSettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var settings: NotificationSettings?

    var body: some View {
        Form {
            Section("Notification Style") {
                Picker("Style:", selection: Binding(
                    get: { settings?.style ?? "fullScreenBlur" },
                    set: { settings?.style = $0; saveSettings() }
                )) {
                    Text("Small Popup (standard)").tag("smallPopup")
                    Text("Full-Screen Blur (unmissable)").tag("fullScreenBlur")
                }
                .pickerStyle(.radioGroup)
            }

            Section("Auto-Close") {
                Toggle("Auto-close after 10 seconds", isOn: Binding(
                    get: { settings?.autoCloseAfter10Seconds ?? false },
                    set: { settings?.autoCloseAfter10Seconds = $0; saveSettings() }
                ))

                Text("When enabled, notifications will automatically dismiss after 10 seconds")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("Sound") {
                Toggle("Play notification sound", isOn: Binding(
                    get: { settings?.playSound ?? true },
                    set: { settings?.playSound = $0; saveSettings() }
                ))

                if settings?.playSound == true {
                    Picker("Sound:", selection: Binding(
                        get: { settings?.selectedSound ?? "Alert" },
                        set: { settings?.selectedSound = $0; saveSettings() }
                    )) {
                        ForEach(Constants.alertSounds, id: \.self) { sound in
                            Text(sound).tag(sound)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }

            Section("Snooze Durations") {
                Text("Select which snooze options to show:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                ForEach(Constants.snoozeDurations, id: \.self) { duration in
                    Toggle("\(duration) minute\(duration == 1 ? "" : "s")", isOn: Binding(
                        get: { settings?.isSnoozeDurationEnabled(duration) ?? true },
                        set: { _ in settings?.toggleSnoozeDuration(duration); saveSettings() }
                    ))
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Notifications")
        .onAppear {
            loadSettings()
        }
    }

    private func loadSettings() {
        if let appSettings = dataManager.fetchSettings() {
            settings = appSettings.notifications
        }
    }

    private func saveSettings() {
        guard let appSettings = dataManager.fetchSettings() else { return }
        dataManager.updateSettings(appSettings)
    }
}

#Preview {
    NotificationSettingsView()
        .environmentObject(DataManager.shared)
}
