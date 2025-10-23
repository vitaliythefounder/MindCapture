//
//  Idea.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import Foundation
import SwiftData

@Model
final class Idea {
    var id: UUID
    var title: String
    var notes: String
    var category: Category?
    var tags: [String]
    var createdAt: Date
    var updatedAt: Date

    // Rich content support
    var imageURLs: [String]
    var links: [String]

    // Conversion tracking
    var convertedToTask: Bool
    var taskID: UUID?

    init(
        title: String,
        notes: String = "",
        category: Category? = nil,
        tags: [String] = []
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.category = category
        self.tags = tags
        self.createdAt = Date()
        self.updatedAt = Date()
        self.imageURLs = []
        self.links = []
        self.convertedToTask = false
        self.taskID = nil
    }

    func convertToTask(dueDate: Date) -> Task {
        let task = Task(
            title: self.title,
            notes: self.notes,
            dueDate: dueDate,
            category: self.category
        )
        self.convertedToTask = true
        self.taskID = task.id
        return task
    }

    func addTag(_ tag: String) {
        if !tags.contains(tag) {
            tags.append(tag)
            updatedAt = Date()
        }
    }

    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
        updatedAt = Date()
    }
}
