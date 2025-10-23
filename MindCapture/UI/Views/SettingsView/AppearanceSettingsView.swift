//
//  AppearanceSettingsView.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import SwiftUI

struct AppearanceSettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var settings: AppearanceSettings?

    var body: some View {
        Form {
            Section("Theme") {
                Picker("Appearance:", selection: Binding(
                    get: { settings?.theme ?? "auto" },
                    set: { settings?.theme = $0; saveSettings() }
                )) {
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                    Text("Auto (system)").tag("auto")
                }
                .pickerStyle(.radioGroup)
            }

            Section("Alert Appearance") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Background blur:")
                    HStack {
                        Slider(
                            value: Binding(
                                get: { settings?.alertBackgroundBlur ?? 0.8 },
                                set: { settings?.alertBackgroundBlur = $0; saveSettings() }
                            ),
                            in: 0.0...1.0
                        )
                        Text("\(Int((settings?.alertBackgroundBlur ?? 0.8) * 100))%")
                            .frame(width: 50, alignment: .trailing)
                            .foregroundColor(.secondary)
                    }
                }

                HStack {
                    Text("Accent color:")
                    Spacer()
                    ColorPicker("", selection: Binding(
                        get: { settings?.accentColor ?? .blue },
                        set: { settings?.setAccentColor($0); saveSettings() }
                    ))
                    .labelsHidden()
                }

                Picker("Font size:", selection: Binding(
                    get: { settings?.fontSize ?? "medium" },
                    set: { settings?.fontSize = $0; saveSettings() }
                )) {
                    Text("Small").tag("small")
                    Text("Medium").tag("medium")
                    Text("Large").tag("large")
                }
                .pickerStyle(.menu)
            }

            Section("Preview") {
                AlertPreview(settings: settings ?? AppearanceSettings())
                    .frame(height: 200)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Appearance")
        .onAppear {
            loadSettings()
        }
    }

    private func loadSettings() {
        if let appSettings = dataManager.fetchSettings() {
            settings = appSettings.appearance
        }
    }

    private func saveSettings() {
        dataManager.updateSettings(dataManager.fetchSettings()!)
    }
}

struct AlertPreview: View {
    let settings: AppearanceSettings

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(Double(settings.alertBackgroundBlur))

            VStack(spacing: 12) {
                Image(systemName: "bell.fill")
                    .font(.system(size: fontSize))
                    .foregroundColor(settings.accentColor)

                Text("Sample Alert")
                    .font(.system(size: fontSize, weight: .semibold))

                Text("This is how your alerts will look")
                    .font(.system(size: fontSize * 0.8))
                    .foregroundColor(.secondary)
            }
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(settings.accentColor, lineWidth: 2)
        )
    }

    private var fontSize: CGFloat {
        switch settings.fontSize {
        case "small": return 14
        case "large": return 20
        default: return 16
        }
    }
}

#Preview {
    AppearanceSettingsView()
        .environmentObject(DataManager.shared)
}
