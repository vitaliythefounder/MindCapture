//
//  CategoryEngine.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import Foundation

@MainActor
class CategoryEngine: ObservableObject {
    private let claudeClient: ClaudeClient
    @Published var isProcessing = false

    init(claudeClient: ClaudeClient) {
        self.claudeClient = claudeClient
    }

    /// Auto-categorizes a task using AI
    func categorize(title: String, notes: String?) async throws -> String {
        isProcessing = true
        defer { isProcessing = false }

        let fullText = [title, notes].compactMap { $0 }.joined(separator: " ")

        let systemPrompt = """
        You are a categorization assistant for MindCapture.
        Categorize tasks into ONE of these categories:
        - Health (exercise, doctor, wellness, medication, fitness)
        - Family (family events, calls with relatives, kids activities)
        - Work (meetings, projects, deadlines, professional tasks)
        - Finance (bills, taxes, investments, banking, budget)
        - Learning (courses, books, study, research, education)
        - Creative (art, writing, music, design, projects)
        - Travel (trips, vacation, booking, planning)
        - Shopping (groceries, purchases, errands)
        - Tech (coding, software, hardware, IT tasks)
        - Other (anything that doesn't fit above)

        Respond with ONLY the category name, nothing else.
        """

        let response = try await claudeClient.sendPrompt(
            "Categorize: \(fullText)",
            systemPrompt: systemPrompt,
            temperature: 0.3
        )

        return response.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Quick local categorization using keyword matching
    func categorizeLocally(title: String, notes: String?) -> String {
        let fullText = [title, notes].compactMap { $0 }.joined(separator: " ").lowercased()

        // Health keywords
        if fullText.contains("doctor") || fullText.contains("workout") ||
           fullText.contains("gym") || fullText.contains("exercise") ||
           fullText.contains("health") || fullText.contains("medication") ||
           fullText.contains("appointment") {
            return "Health"
        }

        // Family keywords
        if fullText.contains("mom") || fullText.contains("dad") ||
           fullText.contains("family") || fullText.contains("kids") ||
           fullText.contains("children") || fullText.contains("spouse") ||
           fullText.contains("parent") {
            return "Family"
        }

        // Work keywords
        if fullText.contains("meeting") || fullText.contains("work") ||
           fullText.contains("project") || fullText.contains("deadline") ||
           fullText.contains("client") || fullText.contains("boss") ||
           fullText.contains("presentation") || fullText.contains("zoom") ||
           fullText.contains("teams") || fullText.contains("email") {
            return "Work"
        }

        // Finance keywords
        if fullText.contains("bill") || fullText.contains("tax") ||
           fullText.contains("bank") || fullText.contains("money") ||
           fullText.contains("payment") || fullText.contains("invest") ||
           fullText.contains("budget") || fullText.contains("$") {
            return "Finance"
        }

        // Learning keywords
        if fullText.contains("learn") || fullText.contains("study") ||
           fullText.contains("course") || fullText.contains("book") ||
           fullText.contains("read") || fullText.contains("research") ||
           fullText.contains("education") {
            return "Learning"
        }

        // Creative keywords
        if fullText.contains("design") || fullText.contains("art") ||
           fullText.contains("music") || fullText.contains("write") ||
           fullText.contains("creative") || fullText.contains("paint") ||
           fullText.contains("draw") {
            return "Creative"
        }

        // Travel keywords
        if fullText.contains("travel") || fullText.contains("trip") ||
           fullText.contains("vacation") || fullText.contains("flight") ||
           fullText.contains("hotel") || fullText.contains("booking") {
            return "Travel"
        }

        // Shopping keywords
        if fullText.contains("buy") || fullText.contains("shop") ||
           fullText.contains("grocery") || fullText.contains("store") ||
           fullText.contains("purchase") || fullText.contains("order") {
            return "Shopping"
        }

        // Tech keywords
        if fullText.contains("code") || fullText.contains("program") ||
           fullText.contains("software") || fullText.contains("tech") ||
           fullText.contains("computer") || fullText.contains("app") ||
           fullText.contains("website") || fullText.contains("debug") {
            return "Tech"
        }

        return "Other"
    }

    /// Batch categorize multiple tasks
    func categorizeBatch(tasks: [(title: String, notes: String?)]) async throws -> [String] {
        // For now, categorize locally to avoid multiple API calls
        // In production, you might want to batch these into a single API call
        return tasks.map { categorizeLocally(title: $0.title, notes: $0.notes) }
    }
}
