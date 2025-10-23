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
                
                Toggle("Pause non-urgent alerts", isOn: Binding(
                    get: { settings?.pauseNonUrgentAlerts ?? true },
                    set: { settings?.pauseNonUrgentAlerts = $0; saveSettings() }
                ))
                
                Toggle("Show visual indicator", isOn: Binding(
                    get: { settings?.showVisualIndicator ?? true },
                    set: { settings?.showVisualIndicator = $0; saveSettings() }
                ))
            }
            
            Section("Ambient Sound") {
                Picker("Sound:", selection: Binding(
                    get: { settings?.ambientSound ?? "off" },
                    set: { settings?.ambientSound = $0; saveSettings() }
                )) {
                    Text("Off").tag("off")
                    Text("Ticking").tag("ticking")
                    Text("Heartbeat").tag("heartbeat")
                    Text("Binaural").tag("binaural")
                    Text("Relax Beat").tag("relaxBeat")
                }
                .pickerStyle(.menu)
                
                HStack {
                    Text("Volume:")
                    Slider(value: Binding(
                        get: { Double(settings?.soundVolume ?? 0.7) },
                        set: { settings?.soundVolume = Float($0); saveSettings() }
                    ), in: 0.0...1.0)
                    Text("\(Int((settings?.soundVolume ?? 0.7) * 100))%")
                        .frame(width: 40)
                }
            }
            
            Section {
                Text("Focus Mode reduces distractions by filtering alerts and providing ambient sounds to help you concentrate.")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
        guard let appSettings = dataManager.fetchSettings() else { return }
        dataManager.updateSettings(appSettings)
    }
}

#Preview {
    FocusModeSettingsView()
        .environmentObject(DataManager.shared)
}