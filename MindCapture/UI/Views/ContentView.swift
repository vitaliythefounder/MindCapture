//
//  ContentView.swift
//  MindCapture
//
//  Created by Vitaliy Fylyk on 10/23/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [Task]
    @Query private var ideas: [Idea]
    @State private var selectedSection: Section = .tasks

    enum Section: String, CaseIterable {
        case tasks = "Tasks"
        case ideas = "Ideas"
        case settings = "Settings"
    }

    var body: some View {
        NavigationSplitView {
            List(Section.allCases, id: \.self, selection: $selectedSection) { section in
                Label(section.rawValue, systemImage: section.icon)
                    .badge(section.badge(tasks: tasks, ideas: ideas))
            }
            .navigationTitle("MindCapture")
            .frame(minWidth: 200)
        } detail: {
            Group {
                switch selectedSection {
                case .tasks:
                    TaskListView()
                case .ideas:
                    IdeasListView()
                case .settings:
                    SettingsView()
                }
            }
        }
    }
}

// MARK: - Task List View
struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.dueDate) private var tasks: [Task]
    @State private var showingAddTask = false

    var body: some View {
        List {
            if tasks.isEmpty {
                ContentUnavailableView(
                    "No Tasks",
                    systemImage: "checkmark.circle",
                    description: Text("Create your first task to get started")
                )
            } else {
                ForEach(tasks) { task in
                    TaskRow(task: task)
                }
                .onDelete(perform: deleteTasks)
            }
        }
        .navigationTitle("Tasks")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddTask = true }) {
                    Label("Add Task", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskSheet()
        }
    }

    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(tasks[index])
            }
        }
    }
}

// MARK: - Task Row
struct TaskRow: View {
    @Bindable var task: Task

    var body: some View {
        HStack {
            Button(action: { task.markCompleted() }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.title)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .secondary : .primary)

                    if task.isMeeting {
                        Image(systemName: "video.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                }

                if let dueDate = task.dueDate {
                    Text(dueDate, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let category = task.category {
                    HStack(spacing: 4) {
                        Image(systemName: category.icon)
                        Text(category.name)
                    }
                    .font(.caption)
                    .foregroundColor(category.color)
                }
            }

            Spacer()

            if task.isOverdue && !task.isCompleted {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Task Sheet
struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]

    @State private var title = ""
    @State private var notes = ""
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var selectedCategory: Category?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Task Title", text: $title)

                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(3...6)

                Toggle("Set due date", isOn: $hasDueDate)

                if hasDueDate {
                    DatePicker("Due Date", selection: $dueDate)
                }

                if !categories.isEmpty {
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(nil as Category?)
                        ForEach(categories) { category in
                            Label(category.name, systemImage: category.icon)
                                .tag(category as Category?)
                        }
                    }
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addTask()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }

    private func addTask() {
        let task = Task(
            title: title,
            notes: notes,
            dueDate: hasDueDate ? dueDate : nil,
            category: selectedCategory
        )
        modelContext.insert(task)
    }
}

// MARK: - Ideas List View
struct IdeasListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Idea.updatedAt, order: .reverse) private var ideas: [Idea]
    @State private var showingAddIdea = false

    var body: some View {
        List {
            if ideas.isEmpty {
                ContentUnavailableView(
                    "No Ideas",
                    systemImage: "lightbulb",
                    description: Text("Capture your first idea")
                )
            } else {
                ForEach(ideas) { idea in
                    IdeaRow(idea: idea)
                }
                .onDelete(perform: deleteIdeas)
            }
        }
        .navigationTitle("Ideas")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddIdea = true }) {
                    Label("Add Idea", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddIdea) {
            AddIdeaSheet()
        }
    }

    private func deleteIdeas(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(ideas[index])
            }
        }
    }
}

// MARK: - Idea Row
struct IdeaRow: View {
    let idea: Idea

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(idea.title)
                .font(.headline)

            if !idea.notes.isEmpty {
                Text(idea.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            if !idea.tags.isEmpty {
                HStack {
                    ForEach(idea.tags.prefix(3), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }

            if let category = idea.category {
                HStack(spacing: 4) {
                    Image(systemName: category.icon)
                    Text(category.name)
                }
                .font(.caption)
                .foregroundColor(category.color)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Idea Sheet
struct AddIdeaSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]

    @State private var title = ""
    @State private var notes = ""
    @State private var tagInput = ""
    @State private var tags: [String] = []
    @State private var selectedCategory: Category?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Idea Title", text: $title)

                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(3...6)

                HStack {
                    TextField("Add tag", text: $tagInput)
                        .onSubmit(addTag)
                    Button("Add", action: addTag)
                        .disabled(tagInput.isEmpty)
                }

                if !tags.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(tags, id: \.self) { tag in
                                HStack {
                                    Text("#\(tag)")
                                    Button(action: { removeTag(tag) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                            }
                        }
                    }
                }

                if !categories.isEmpty {
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(nil as Category?)
                        ForEach(categories) { category in
                            Label(category.name, systemImage: category.icon)
                                .tag(category as Category?)
                        }
                    }
                }
            }
            .navigationTitle("New Idea")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addIdea()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }

    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            tags.append(trimmed)
            tagInput = ""
        }
    }

    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    private func addIdea() {
        let idea = Idea(
            title: title,
            notes: notes,
            category: selectedCategory,
            tags: tags
        )
        modelContext.insert(idea)
    }
}

// MARK: - Section Extension
extension ContentView.Section {
    var icon: String {
        switch self {
        case .tasks: return "checkmark.circle"
        case .ideas: return "lightbulb"
        case .settings: return "gear"
        }
    }

    func badge(tasks: [Task], ideas: [Idea]) -> Int? {
        switch self {
        case .tasks:
            return tasks.filter { !$0.isCompleted }.count
        case .ideas:
            return ideas.count
        case .settings:
            return nil
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager.shared)
        .modelContainer(DataManager.shared.modelContainer)
}
