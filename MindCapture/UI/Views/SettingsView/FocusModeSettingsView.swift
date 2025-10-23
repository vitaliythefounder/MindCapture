//
//  FocusModeSettingsView.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import SwiftUI

struct FocusModeSettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var settings: FocusModeSettings?

    var body: some View {
        Form {
            Section("Focus Mode") {
                Toggle("Enable Focus Mode", isOn: Binding(
                    get: { settings?.enabled ?? false },
                    set: { settings?.enabled = $0; saveSettings() }
                ))
            }

            if settings?.enabled == true {
                Section("Behavior") {
                    Toggle("Pause non-urgent alerts", isOn: Binding(
                        get: { settings?.pauseNonUrgentAlerts ?? true },
                        set: { settings?.pauseNonUrgentAlerts = $0; saveSettings() }
                    ))

                    Toggle("Show visual focus indicator", isOn: Binding(
                        get: { settings?.showVisualIndicator ?? true },
                        set: { settings?.showVisualIndicator = $0; saveSettings() }
                    ))
                }

                Section("Ambient Sounds") {
                    Picker("Sound:", selection: Binding(
                        get: { settings?.ambientSound ?? "off" },
                        set: { settings?.ambientSound = $0; saveSettings() }
                    )) {
                        Text("Off").tag("off")
                        Text("Ticking").tag("ticking")
                        Text("Heartbeat").tag("heartbeat")
                        Text("Binaural Beats").tag("binaural")
                        Text("Relax Beat").tag("relaxBeat")
                    }
                    .pickerStyle(.radioGroup)

                    if settings?.ambientSound != "off" {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Volume:")
                            HStack {
                                Image(systemName: "speaker.fill")
                                    .foregroundColor(.secondary)
                                Slider(
                                    value: Binding(
                                        get: { settings?.soundVolume ?? 0.7 },
                                        set: { settings?.soundVolume = $0; saveSettings() }
                                    ),
                                    in: 0.0...1.0
                                )
                                Image(systemName: "speaker.wave.3.fill")
                                    .foregroundColor(.secondary)
                            }
                            Text("\(Int((settings?.soundVolume ?? 0.7) * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section {
                    Text("Focus Mode helps you stay concentrated by reducing distractions and playing calming sounds.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Focus Mode")
        .onAppear {
            loadSettings()
        }
    }

    private func loadSettings() {
        if let appSettings = dataManager.fetchSettings() {
            settings = appSettings.focusMode
        }
    }

    private func saveSettings() {
        dataManager.updateSettings(dataManager.fetchSettings()!)
    }
}

#Preview {
    FocusModeSettingsView()
        .environmentObject(DataManager.shared)
}
