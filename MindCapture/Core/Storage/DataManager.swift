//
//  DataManager.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import Foundation
import SwiftData
import Combine

@MainActor
class DataManager: ObservableObject {
    static let shared = DataManager()

    let modelContainer: ModelContainer
    let modelContext: ModelContext

    private init() {
        let schema = Schema([
            Task.self,
            Idea.self,
            Category.self,
            AppSettings.self,
            GeneralSettings.self,
            WidgetSettings.self,
            NotificationSettings.self,
            SyncSettings.self,
            FocusModeSettings.self,
            ShortcutSettings.self,
            AppearanceSettings.self,
            AISettings.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.modelContext = modelContainer.mainContext
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }

        // Initialize default data if needed
        initializeDefaults()
    }

    // MARK: - Initialization
    private func initializeDefaults() {
        // Check if categories exist, if not create defaults
        let categoryDescriptor = FetchDescriptor<Category>()
        let existingCategories = (try? modelContext.fetch(categoryDescriptor)) ?? []

        if existingCategories.isEmpty {
            // Create default categories
            for defaultCategory in Category.defaultCategories {
                modelContext.insert(defaultCategory)
            }
        }

        // Check if settings exist, if not create defaults
        let settingsDescriptor = FetchDescriptor<AppSettings>()
        let existingSettings = (try? modelContext.fetch(settingsDescriptor)) ?? []

        if existingSettings.isEmpty {
            let appSettings = AppSettings()
            modelContext.insert(appSettings)
        }

        // Save initial setup
        try? modelContext.save()
    }

    // MARK: - Task Operations
    func createTask(title: String, notes: String = "", dueDate: Date? = nil, category: Category? = nil) -> Task {
        let task = Task(title: title, notes: notes, dueDate: dueDate, category: category)
        modelContext.insert(task)
        try? modelContext.save()
        return task
    }

    func updateTask(_ task: Task) {
        try? modelContext.save()
    }

    func deleteTask(_ task: Task) {
        modelContext.delete(task)
        try? modelContext.save()
    }

    func fetchTasks() -> [Task] {
        let descriptor = FetchDescriptor<Task>(sortBy: [SortDescriptor(\.dueDate)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchTodaysTasks() -> [Task] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { task in
                guard let dueDate = task.dueDate else { return false }
                return dueDate >= today && dueDate < tomorrow && !task.isCompleted
            },
            sortBy: [SortDescriptor(\.dueDate)]
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchUpcomingTasks(limit: Int = 3) -> [Task] {
        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { task in
                guard let dueDate = task.dueDate, dueDate > Date() else { return false }
                return !task.isCompleted
            },
            sortBy: [SortDescriptor(\.dueDate)]
        )

        let tasks = (try? modelContext.fetch(descriptor)) ?? []
        return Array(tasks.prefix(limit))
    }

    // MARK: - Idea Operations
    func createIdea(title: String, notes: String = "", category: Category? = nil, tags: [String] = []) -> Idea {
        let idea = Idea(title: title, notes: notes, category: category, tags: tags)
        modelContext.insert(idea)
        try? modelContext.save()
        return idea
    }

    func updateIdea(_ idea: Idea) {
        idea.updatedAt = Date()
        try? modelContext.save()
    }

    func deleteIdea(_ idea: Idea) {
        modelContext.delete(idea)
        try? modelContext.save()
    }

    func fetchIdeas() -> [Idea] {
        let descriptor = FetchDescriptor<Idea>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Category Operations
    func fetchCategories() -> [Category] {
        let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchCategory(named name: String) -> Category? {
        let descriptor = FetchDescriptor<Category>(
            predicate: #Predicate { category in
                category.name == name
            }
        )
        return try? modelContext.fetch(descriptor).first
    }

    // MARK: - Settings Operations
    func fetchSettings() -> AppSettings? {
        let descriptor = FetchDescriptor<AppSettings>()
        return try? modelContext.fetch(descriptor).first
    }

    func updateSettings(_ settings: AppSettings) {
        try? modelContext.save()
    }

    // MARK: - Statistics
    func getCompletedTasksCount(for period: StatsPeriod) -> Int {
        let startDate = period.startDate
        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { task in
                task.isCompleted && task.completedAt ?? Date.distantPast >= startDate
            }
        )
        return (try? modelContext.fetch(descriptor).count) ?? 0
    }

    enum StatsPeriod {
        case today, week, month

        var startDate: Date {
            let calendar = Calendar.current
            let now = Date()

            switch self {
            case .today:
                return calendar.startOfDay(for: now)
            case .week:
                return calendar.date(byAdding: .day, value: -7, to: now)!
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: now)!
            }
        }
    }
}
