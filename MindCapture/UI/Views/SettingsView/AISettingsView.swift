//
//  AISettingsView.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import SwiftUI

struct AISettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var claudeClient: ClaudeClient
    @State private var settings: AISettings?
    @State private var apiKeyInput: String = ""
    @State private var isTestingKey: Bool = false
    @State private var testResult: TestResult?

    enum TestResult {
        case success
        case failure(String)
    }

    var body: some View {
        Form {
            Section("Claude API Configuration") {
                SecureField("API Key:", text: $apiKeyInput)
                    .onSubmit {
                        saveAPIKey()
                    }

                Picker("Model:", selection: Binding(
                    get: { settings?.model ?? Constants.defaultClaudeModel },
                    set: { settings?.model = $0; saveSettings() }
                )) {
                    Text("Claude Sonnet 4").tag("claude-sonnet-4-20250514")
                    Text("Claude Opus 4").tag("claude-opus-4-20250514")
                }
                .pickerStyle(.menu)

                HStack {
                    Button(isTestingKey ? "Testing..." : "Test API Key") {
                        testAPIKey()
                    }
                    .disabled(apiKeyInput.isEmpty || isTestingKey)

                    if let result = testResult {
                        switch result {
                        case .success:
                            Label("Valid", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        case .failure(let error):
                            Label("Invalid", systemImage: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .help(error)
                        }
                    }
                }
            }

            Section("Default Task Time") {
                HStack {
                    Text("When time not specified:")

                    Picker("Hour", selection: Binding(
                        get: { settings?.defaultTaskHour ?? 9 },
                        set: { settings?.defaultTaskHour = $0; saveSettings() }
                    )) {
                        ForEach(0..<24) { hour in
                            Text(String(format: "%02d", hour)).tag(hour)
                        }
                    }
                    .frame(width: 70)

                    Text(":")

                    Picker("Minute", selection: Binding(
                        get: { settings?.defaultTaskMinute ?? 0 },
                        set: { settings?.defaultTaskMinute = $0; saveSettings() }
                    )) {
                        ForEach([0, 15, 30, 45], id: \.self) { minute in
                            Text(String(format: "%02d", minute)).tag(minute)
                        }
                    }
                    .frame(width: 70)
                }
            }

            Section("Parsing Preferences") {
                Toggle("Auto-categorize tasks", isOn: Binding(
                    get: { settings?.autoCategorize ?? true },
                    set: { settings?.autoCategorize = $0; saveSettings() }
                ))

                Toggle("Enhance text quality", isOn: Binding(
                    get: { settings?.enhanceText ?? true },
                    set: { settings?.enhanceText = $0; saveSettings() }
                ))

                Toggle("Split multi-tasks automatically", isOn: Binding(
                    get: { settings?.splitMultiTasks ?? true },
                    set: { settings?.splitMultiTasks = $0; saveSettings() }
                ))
            }

            Section("Privacy") {
                Toggle("Use local processing when possible", isOn: Binding(
                    get: { settings?.useLocalProcessing ?? false },
                    set: { settings?.useLocalProcessing = $0; saveSettings() }
                ))

                Toggle("Encrypt API communications", isOn: Binding(
                    get: { settings?.encryptCommunications ?? true },
                    set: { settings?.encryptCommunications = $0; saveSettings() }
                ))

                Text("Your API key is stored securely in the system Keychain")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section {
                if let url = URL(string: "https://console.anthropic.com/") {
                    Link("Get API Key from Anthropic", destination: url)
                        .foregroundColor(.blue)
                }

                Text("AI features require a Claude API key. Your key is never shared and only used for parsing tasks.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("AI")
        .onAppear {
            loadSettings()
        }
    }

    private func loadSettings() {
        if let appSettings = dataManager.fetchSettings() {
            settings = appSettings.ai
            apiKeyInput = settings?.apiKey ?? ""
        }
    }

    private func saveSettings() {
        guard let appSettings = dataManager.fetchSettings() else { return }
        dataManager.updateSettings(appSettings)
    }

    private func saveAPIKey() {
        settings?.apiKey = apiKeyInput
        saveSettings()
        claudeClient.updateConfiguration(apiKey: apiKeyInput, model: settings?.model ?? Constants.defaultClaudeModel)
        testResult = nil
    }

    private func testAPIKey() {
        isTestingKey = true
        testResult = nil

        Task {
            claudeClient.updateConfiguration(apiKey: apiKeyInput, model: settings?.model ?? Constants.defaultClaudeModel)
            let isValid = await claudeClient.testAPIKey()

            await MainActor.run {
                isTestingKey = false
                if isValid {
                    testResult = .success
                    saveAPIKey()
                } else {
                    testResult = .failure("Invalid API key or network error")
                }
            }
        }
    }
}

#Preview {
    AISettingsView()
        .environmentObject(DataManager.shared)
        .environmentObject(ClaudeClient())
}
