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
    
    var body: some View {
        Form {
            Section("Display") {
                Picker("Display mode:", selection: Binding(
                    get: { settings?.displayMode ?? "alwaysOnDesktop" },
                    set: { settings?.displayMode = $0; saveSettings() }
                )) {
                    Text("Always On Desktop").tag("alwaysOnDesktop")
                    Text("Menu Bar Only").tag("menuBarOnly")
                    Text("Hidden").tag("hidden")
                }
                .pickerStyle(.menu)
                
                Picker("Size:", selection: Binding(
                    get: { settings?.size ?? "medium" },
                    set: { settings?.size = $0; saveSettings() }
                )) {
                    Text("Small").tag("small")
                    Text("Medium").tag("medium")
                    Text("Large").tag("large")
                }
                .pickerStyle(.segmented)
            }
            
            Section("Position") {
                Picker("Monitor:", selection: Binding(
                    get: { settings?.selectedMonitor ?? "main" },
                    set: { settings?.selectedMonitor = $0; saveSettings() }
                )) {
                    Text("Main Display").tag("main")
                    Text("External Display").tag("external1")
                    Text("All Displays").tag("all")
                }
                .pickerStyle(.menu)
                
                Toggle("Audio/Haptic Experiences", isOn: Binding(
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
        guard let appSettings = dataManager.fetchSettings() else { return }
        dataManager.updateSettings(appSettings)
    }
}

#Preview {
    WidgetSettingsView()
        .environmentObject(DataManager.shared)
}