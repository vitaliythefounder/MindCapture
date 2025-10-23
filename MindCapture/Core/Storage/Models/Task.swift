//
//  Task.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import Foundation
import SwiftData

@Model
final class Task {
    var id: UUID
    var title: String
    var notes: String
    var dueDate: Date?
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    var category: Category?

    // Video conference support
    var videoConferenceService: String?
    var videoConferenceURL: String?

    // Snooze tracking
    var snoozedUntil: Date?
    var snoozeCount: Int

    // Sync information
    var calendarEventID: String?
    var reminderID: String?
    var isSynced: Bool

    // Alert customization
    var alertMinutesBefore: Int?
    var customAlertSound: String?

    init(
        title: String,
        notes: String = "",
        dueDate: Date? = nil,
        category: Category? = nil,
        videoConferenceService: String? = nil,
        videoConferenceURL: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.category = category
        self.isCompleted = false
        self.completedAt = nil
        self.createdAt = Date()
        self.videoConferenceService = videoConferenceService
        self.videoConferenceURL = videoConferenceURL
        self.snoozedUntil = nil
        self.snoozeCount = 0
        self.calendarEventID = nil
        self.reminderID = nil
        self.isSynced = false
        self.alertMinutesBefore = nil
        self.customAlertSound = nil
    }

    var isMeeting: Bool {
        videoConferenceURL != nil
    }

    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return !isCompleted && dueDate < Date()
    }

    var isSnoozed: Bool {
        guard let snoozedUntil = snoozedUntil else { return false }
        return snoozedUntil > Date()
    }

    func snooze(for minutes: Int) {
        self.snoozedUntil = Date().addingTimeInterval(TimeInterval(minutes * 60))
        self.snoozeCount += 1
    }

    func markCompleted() {
        self.isCompleted = true
        self.completedAt = Date()
    }
}
