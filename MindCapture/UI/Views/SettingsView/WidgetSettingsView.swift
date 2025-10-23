//
//  WidgetSettingsView.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import SwiftUI

struct WidgetSettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var settings: WidgetSettings?

    private let displayModes = ["alwaysOnDesktop", "menuBarOnly", "hidden"]
    private let sizes = ["small", "medium", "large"]
    private let monitors = ["main", "external1", "external2", "all"]

    var body: some View {
        Form {
            Section("Display Mode") {
                Picker("Mode:", selection: Binding(
                    get: { settings?.displayMode ?? "alwaysOnDesktop" },
                    set: { settings?.displayMode = $0; saveSettings() }
                )) {
                    Text("Always on Desktop").tag("alwaysOnDesktop")
                    Text("Menu Bar Only").tag("menuBarOnly")
                    Text("Hidden").tag("hidden")
                }
                .pickerStyle(.radioGroup)
            }

            if settings?.displayMode == "alwaysOnDesktop" {
                Section("Widget Appearance") {
                    Picker("Size:", selection: Binding(
                        get: { settings?.size ?? "medium" },
                        set: { settings?.size = $0; saveSettings() }
                    )) {
                        Text("Small (150×100)").tag("small")
                        Text("Medium (200×150)").tag("medium")
                        Text("Large (250×200)").tag("large")
                    }
                    .pickerStyle(.radioGroup)
                }

                Section("Multi-Monitor") {
                    Picker("Display on:", selection: Binding(
                        get: { settings?.selectedMonitor ?? "main" },
                        set: { settings?.selectedMonitor = $0; saveSettings() }
                    )) {
                        Text("Main Display").tag("main")
                        Text("External Display 1").tag("external1")
                        Text("External Display 2").tag("external2")
                        Text("All Displays").tag("all")
                    }
                    .pickerStyle(.menu)
                }

                Section("Position") {
                    HStack {
                        Text("X:")
                        TextField("X", value: Binding(
                            get: { settings?.positionX ?? 0 },
                            set: { settings?.positionX = $0; saveSettings() }
                        ), format: .number)
                        .frame(width: 80)

                        Text("Y:")
                        TextField("Y", value: Binding(
                            get: { settings?.positionY ?? 0 },
                            set: { settings?.positionY = $0; saveSettings() }
                        ), format: .number)
                        .frame(width: 80)
                    }

                    Text("Tip: Drag the widget to reposition it")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Section("Experience") {
                Toggle("Audio-haptic experiences", isOn: Binding(
                    get: { settings?.audioHapticExperiences ?? true },
                    set: { settings?.audioHapticExperiences = $0; saveSettings() }
                ))
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Widget")
        .onAppear {
            loadSettings()
        }
    }

    private func loadSettings() {
        if let appSettings = dataManager.fetchSettings() {
            settings = appSettings.widget
        }
    }

    private func saveSettings() {
        dataManager.updateSettings(dataManager.fetchSettings()!)
    }
}

#Preview {
    WidgetSettingsView()
        .environmentObject(DataManager.shared)
}
