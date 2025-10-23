//
//  AppDelegate.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import Cocoa
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem?
    var quickCaptureWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request notification permissions
        requestNotificationPermissions()

        // Setup menu bar item
        setupMenuBar()

        // Check if should show onboarding
        checkOnboarding()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup and save state
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep app running even if all windows are closed
        return false
    }

    // MARK: - Notification Permissions
    private func requestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Menu Bar Setup
    private func setupMenuBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusBarItem?.button {
            button.image = NSImage(systemSymbolName: "brain.head.profile", accessibilityDescription: "MindCapture")
            button.action = #selector(menuBarItemClicked)
        }

        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Quick Capture", action: #selector(showQuickCapture), keyEquivalent: "l"))
        menu.addItem(NSMenuItem(title: "Today's Tasks", action: #selector(showTodaysTasks), keyEquivalent: "t"))
        menu.addItem(NSMenuItem(title: "Ideas Vault", action: #selector(showIdeas), keyEquivalent: "i"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Focus Mode", action: #selector(toggleFocusMode), keyEquivalent: "f"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(showSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusBarItem?.menu = menu
    }

    // MARK: - Menu Actions
    @objc private func menuBarItemClicked() {
        statusBarItem?.menu?.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }

    @objc private func showQuickCapture() {
        // Will be implemented with QuickCaptureWindow
        print("Show Quick Capture")
    }

    @objc private func showTodaysTasks() {
        // Will be implemented
        print("Show Today's Tasks")
    }

    @objc private func showIdeas() {
        // Will be implemented
        print("Show Ideas")
    }

    @objc private func toggleFocusMode() {
        // Will be implemented
        print("Toggle Focus Mode")
    }

    @objc private func showSettings() {
        // Will be implemented
        print("Show Settings")
    }

    // MARK: - Onboarding
    private func checkOnboarding() {
        let hasCompleted = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKey.hasCompletedOnboarding)
        if !hasCompleted {
            // Show onboarding window
            print("Show onboarding")
        }
    }
}
