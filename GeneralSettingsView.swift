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
                Toggle("Start at launch", isOn: Binding(
                    get: { settings?.startAtLaunch ?? true },
                    set: { settings?.startAtLaunch = $0; saveSettings() }
                ))
            }
            
            Section("Alerts") {
                HStack {
                    Text("Alert minutes before:")
                    Spacer()
                    TextField("Minutes", value: Binding(
                        get: { settings?.alertMinutesBefore ?? 5 },
                        set: { settings?.alertMinutesBefore = $0; saveSettings() }
                    ), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
                }
                
                Toggle("Enable sounds", isOn: Binding(
                    get: { settings?.enableSounds ?? true },
                    set: { settings?.enableSounds = $0; saveSettings() }
                ))
                
                Picker("Alert sound:", selection: Binding(
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