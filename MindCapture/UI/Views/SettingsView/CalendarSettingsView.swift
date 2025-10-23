//
//  CalendarSettingsView.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import SwiftUI
import EventKit

struct CalendarSettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var settings: SyncSettings?
    @State private var availableCalendars: [EKCalendar] = []
    @State private var availableReminderLists: [EKCalendar] = []
    @State private var eventStore = EKEventStore()

    var body: some View {
        Form {
            Section("Calendars") {
                if availableCalendars.isEmpty {
                    Text("No calendars found. Check Calendar app permissions.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(availableCalendars, id: \.calendarIdentifier) { calendar in
                        Toggle(calendar.title, isOn: Binding(
                            get: { settings?.isCalendarSelected(calendar.calendarIdentifier) ?? false },
                            set: { _ in
                                settings?.toggleCalendar(calendar.calendarIdentifier)
                                saveSettings()
                            }
                        ))
                        .badge(calendar.source.title)
                    }
                }
            }

            Section("Reminder Lists") {
                if availableReminderLists.isEmpty {
                    Text("No reminder lists found. Check Reminders app permissions.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(availableReminderLists, id: \.calendarIdentifier) { list in
                        Toggle(list.title, isOn: Binding(
                            get: { settings?.isReminderListSelected(list.calendarIdentifier) ?? false },
                            set: { _ in
                                settings?.toggleReminderList(list.calendarIdentifier)
                                saveSettings()
                            }
                        ))
                    }
                }
            }

            Section("Sync Options") {
                Toggle("Sync new tasks to Reminders app", isOn: Binding(
                    get: { settings?.syncTasksToReminders ?? true },
                    set: { settings?.syncTasksToReminders = $0; saveSettings() }
                ))

                Toggle("Sync meetings to Calendar app", isOn: Binding(
                    get: { settings?.syncMeetingsToCalendar ?? true },
                    set: { settings?.syncMeetingsToCalendar = $0; saveSettings() }
                ))
            }

            Section("Sync Status") {
                if let lastSync = settings?.lastSyncDate {
                    HStack {
                        Text("Last sync:")
                        Spacer()
                        Text(lastSync, style: .relative)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Never synced")
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
            requestPermissionsAndLoadData()
        }
    }

    private func loadSettings() {
        if let appSettings = dataManager.fetchSettings() {
            settings = appSettings.sync
        }
    }

    private func saveSettings() {
        dataManager.updateSettings(dataManager.fetchSettings()!)
    }

    private func requestPermissionsAndLoadData() {
        // Request calendar access
        eventStore.requestFullAccessToEvents { granted, error in
            if granted {
                DispatchQueue.main.async {
                    availableCalendars = eventStore.calendars(for: .event)
                }
            }
        }

        // Request reminders access
        eventStore.requestFullAccessToReminders { granted, error in
            if granted {
                DispatchQueue.main.async {
                    availableReminderLists = eventStore.calendars(for: .reminder)
                }
            }
        }
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
