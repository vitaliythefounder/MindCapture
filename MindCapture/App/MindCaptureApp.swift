//
//  MindCaptureApp.swift
//  MindCapture
//
//  Created by Vitaliy Fylyk on 10/23/25.
//

import SwiftUI
import SwiftData

@main
struct MindCaptureApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var claudeClient = ClaudeClient()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .environmentObject(claudeClient)
        }
        .modelContainer(dataManager.modelContainer)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About MindCapture") {
                    showAboutWindow()
                }
            }
        }

        Settings {
            SettingsView()
                .environmentObject(dataManager)
                .environmentObject(claudeClient)
        }
    }

    private func showAboutWindow() {
        let alert = NSAlert()
        alert.messageText = "MindCapture"
        alert.informativeText = "Version \(Constants.appVersion)\n\nAI-powered productivity for your mind."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
