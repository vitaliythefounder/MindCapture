//
//  GeneralSettingsView.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import SwiftUI

struct GeneralSettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var settings: GeneralSettings?

    var body: some View {
        Form {
            Section("Startup") {
                Toggle("Start app at login", isOn: Binding(
                    get: { settings?.startAtLaunch ?? true },
                    set: { settings?.startAtLaunch = $0; saveSettings() }
                ))

                Toggle("Show onboarding on first launch", isOn: Binding(
                    get: { settings?.showOnboarding ?? true },
                    set: { settings?.showOnboarding = $0; saveSettings() }
                ))
            }

            Section("Alert Timing") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Alert me before events:")
                    HStack {
                        Slider(
                            value: Binding(
                                get: { Double(settings?.alertMinutesBefore ?? 5) },
                                set: { settings?.alertMinutesBefore = Int($0); saveSettings() }
                            ),
                            in: Double(Constants.minAlertMinutes)...Double(Constants.maxAlertMinutes),
                            step: 1
                        )
                        Text("\(settings?.alertMinutesBefore ?? 5) min")
                            .frame(width: 60, alignment: .trailing)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section("Sounds") {
                Toggle("Enable notification sounds", isOn: Binding(
                    get: { settings?.enableSounds ?? true },
                    set: { settings?.enableSounds = $0; saveSettings() }
                ))

                if settings?.enableSounds == true {
                    Picker("Notification sound:", selection: Binding(
                        get: { settings?.selectedSound ?? "Default" },
                        set: { settings?.selectedSound = $0; saveSettings() }
                    )) {
                        ForEach(Constants.alertSounds, id: \.self) { sound in
                            Text(sound).tag(sound)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("General")
        .onAppear {
            loadSettings()
        }
    }

    private func loadSettings() {
        if let appSettings = dataManager.fetchSettings() {
            settings = appSettings.general
        }
    }

    private func saveSettings() {
        guard let appSettings = dataManager.fetchSettings() else { return }
        dataManager.updateSettings(appSettings)
    }
}

#Preview {
    GeneralSettingsView()
        .environmentObject(DataManager.shared)
}
