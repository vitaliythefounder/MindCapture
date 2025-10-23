//
//  TaskParser.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import Foundation

struct ParsedTask: Codable {
    let title: String
    let notes: String?
    let dueDate: Date?
    let category: String?
    let isIdea: Bool
}

struct ParsedResult: Codable {
    let tasks: [ParsedTask]
    let type: String // "task", "meeting", "idea"
}

@MainActor
class TaskParser: ObservableObject {
    private let claudeClient: ClaudeClient
    @Published var isProcessing = false

    init(claudeClient: ClaudeClient) {
        self.claudeClient = claudeClient
    }

    /// Parses natural language input into structured tasks
    func parse(input: String, settings: AISettings) async throws -> ParsedResult {
        isProcessing = true
        defer { isProcessing = false }

        let systemPrompt = """
        You are a task parsing assistant for MindCapture, a productivity app.
        Parse the user's input and extract structured task information.

        RULES:
        1. Split multi-tasks (e.g., "Do X and Y" → 2 tasks)
        2. Parse dates/times: "today", "tomorrow", "next week", "at 8pm", "Saturday", "in 2 hours"
        3. Detect type: task, meeting (has video conference link), or idea (starts with "idea:" or is exploratory)
        4. Auto-categorize into: Health, Family, Work, Finance, Learning, Creative, Travel, Shopping, Tech, Other
        5. Enhance text: Fix grammar, make concise, keep user's intent
        6. Extract video conference links and mark as meeting

        Default task time if not specified: \(settings.defaultTaskHour):\(String(format: "%02d", settings.defaultTaskMinute))

        Respond ONLY with valid JSON in this format:
        {
          "tasks": [
            {
              "title": "Enhanced task title",
              "notes": "Additional notes or context",
              "dueDate": "2025-10-23T20:00:00Z" or null,
              "category": "Work" or null,
              "isIdea": false
            }
          ],
          "type": "task" | "meeting" | "idea"
        }

        If no specific time is mentioned but a date is given, use the default time.
        """

        let response = try await claudeClient.sendPrompt(
            "Parse this: \(input)",
            systemPrompt: systemPrompt,
            temperature: 0.3 // Lower temperature for more consistent parsing
        )

        // Clean the response to extract JSON
        let jsonString = extractJSON(from: response)

        guard let data = jsonString.data(using: .utf8) else {
            throw ClaudeError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let result = try decoder.decode(ParsedResult.self, from: data)
            return result
        } catch {
            print("Failed to decode response: \(error)")
            print("Response was: \(response)")
            throw ClaudeError.decodingError(error)
        }
    }

    /// Extracts JSON from Claude's response (handles markdown code blocks)
    private func extractJSON(from response: String) -> String {
        // Remove markdown code blocks if present
        var cleaned = response
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Find first { and last }
        if let firstBrace = cleaned.firstIndex(of: "{"),
           let lastBrace = cleaned.lastIndex(of: "}") {
            cleaned = String(cleaned[firstBrace...lastBrace])
        }

        return cleaned
    }

    /// Quick local parsing for simple cases (no API call needed)
    func parseLocally(input: String, settings: AISettings) -> ParsedResult {
        var tasks: [ParsedTask] = []

        // Check if it's an idea
        let isIdea = input.lowercased().starts(with: "idea:")

        // Simple split on "and" for multi-tasks
        let splitTasks = input.components(separatedBy: " and ")

        for taskText in splitTasks {
            var title = taskText.trimmingCharacters(in: .whitespaces)
            if isIdea {
                title = title.replacingOccurrences(of: "idea:", with: "", options: .caseInsensitive)
                    .trimmingCharacters(in: .whitespaces)
            }

            // Simple date parsing
            let dueDate = parseSimpleDate(from: title, settings: settings)

            tasks.append(ParsedTask(
                title: title,
                notes: nil,
                dueDate: dueDate,
                category: nil,
                isIdea: isIdea
            ))
        }

        return ParsedResult(
            tasks: tasks,
            type: isIdea ? "idea" : "task"
        )
    }

    /// Simple date parser for common phrases
    private func parseSimpleDate(from text: String, settings: AISettings) -> Date? {
        let lowercased = text.lowercased()
        var calendar = Calendar.current
        let now = Date()

        if lowercased.contains("today") {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = settings.defaultTaskHour
            components.minute = settings.defaultTaskMinute
            return calendar.date(from: components)
        } else if lowercased.contains("tomorrow") {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.day? += 1
            components.hour = settings.defaultTaskHour
            components.minute = settings.defaultTaskMinute
            return calendar.date(from: components)
        } else if lowercased.contains("next week") {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.day? += 7
            components.hour = settings.defaultTaskHour
            components.minute = settings.defaultTaskMinute
            return calendar.date(from: components)
        }

        // Parse "at XXpm" or "at XX:XXpm"
        if let timeMatch = try? NSRegularExpression(pattern: #"at (\d{1,2}):?(\d{2})?\s*(am|pm)"#, options: .caseInsensitive)
            .firstMatch(in: lowercased, range: NSRange(lowercased.startIndex..., in: lowercased)) {

            if let hourRange = Range(timeMatch.range(at: 1), in: lowercased),
               let hour = Int(lowercased[hourRange]) {

                let minute: Int
                if timeMatch.range(at: 2).location != NSNotFound,
                   let minuteRange = Range(timeMatch.range(at: 2), in: lowercased) {
                    minute = Int(lowercased[minuteRange]) ?? 0
                } else {
                    minute = 0
                }

                let isPM = lowercased.contains("pm")
                let hour24 = isPM && hour != 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour)

                var components = calendar.dateComponents([.year, .month, .day], from: now)
                components.hour = hour24
                components.minute = minute
                return calendar.date(from: components)
            }
        }

        return nil
    }
}
