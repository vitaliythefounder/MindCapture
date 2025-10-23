//
//  CalendarSettingsView.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import SwiftUI

struct CalendarSettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var settings: SyncSettings?
    
    var body: some View {
        Form {
            Section("Synchronization") {
                Toggle("Sync tasks to Reminders", isOn: Binding(
                    get: { settings?.syncTasksToReminders ?? true },
                    set: { settings?.syncTasksToReminders = $0; saveSettings() }
                ))
                
                Toggle("Sync meetings to Calendar", isOn: Binding(
                    get: { settings?.syncMeetingsToCalendar ?? true },
                    set: { settings?.syncMeetingsToCalendar = $0; saveSettings() }
                ))
            }
            
            Section("Calendars") {
                Text("Select calendars to sync with:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Note: In a real implementation, you would fetch available calendars
                Text("No calendars available")
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            Section("Reminder Lists") {
                Text("Select reminder lists to sync with:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Note: In a real implementation, you would fetch available reminder lists
                Text("No reminder lists available")
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            Section("Sync Status") {
                if let lastSync = settings?.lastSyncDate {
                    Text("Last sync: \(lastSync, format: Date.FormatStyle(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Never synced")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button("Sync Now") {
                    performSync()
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Calendars & Reminders")
        .onAppear {
            loadSettings()
        }
    }
    
    private func loadSettings() {
        if let appSettings = dataManager.fetchSettings() {
            settings = appSettings.sync
        }
    }
    
    private func saveSettings() {
        guard let appSettings = dataManager.fetchSettings() else { return }
        dataManager.updateSettings(appSettings)
    }
    
    private func performSync() {
        settings?.lastSyncDate = Date()
        saveSettings()
        // TODO: Implement actual sync logic
    }
}

#Preview {
    CalendarSettingsView()
        .environmentObject(DataManager.shared)
}