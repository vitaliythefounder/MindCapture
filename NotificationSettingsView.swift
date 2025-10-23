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
                    Text("Small Popup").tag("smallPopup")
                    Text("Full-Screen Blur").tag("fullScreenBlur")
                }
                .pickerStyle(.segmented)
                
                Toggle("Auto-close after 10 seconds", isOn: Binding(
                    get: { settings?.autoCloseAfter10Seconds ?? false },
                    set: { settings?.autoCloseAfter10Seconds = $0; saveSettings() }
                ))
            }
            
            Section("Sound") {
                Toggle("Play sound", isOn: Binding(
                    get: { settings?.playSound ?? true },
                    set: { settings?.playSound = $0; saveSettings() }
                ))
                
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
            
            Section("Snooze Options") {
                Text("Available snooze durations:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(Constants.snoozeDurations, id: \.self) { minutes in
                    Toggle("\(minutes) minute\(minutes == 1 ? "" : "s")", isOn: Binding(
                        get: { settings?.isSnoozeDurationEnabled(minutes) ?? true },
                        set: { _ in settings?.toggleSnoozeDuration(minutes); saveSettings() }
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