//
//  TextEnhancer.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import Foundation
import Combine

@MainActor
class TextEnhancer: ObservableObject {
    private let claudeClient: ClaudeClient
    @Published var isProcessing = false

    init(claudeClient: ClaudeClient) {
        self.claudeClient = claudeClient
    }

    /// Enhances task text using AI
    /// - Parameters:
    ///   - text: Original text to enhance
    ///   - preserveIntent: Whether to strictly preserve user's original intent
    /// - Returns: Enhanced text
    func enhance(_ text: String, preserveIntent: Bool = true) async throws -> String {
        isProcessing = true
        defer { isProcessing = false }

        let systemPrompt = """
        You are a text enhancement assistant for MindCapture.
        Improve the given text by:
        1. Fixing grammar and spelling
        2. Making it more concise and clear
        3. Preserving the user's original intent and meaning
        4. Keeping the same tone and style
        5. NOT adding information that wasn't in the original

        Respond with ONLY the enhanced text, nothing else.
        """

        let response = try await claudeClient.sendPrompt(
            "Enhance: \(text)",
            systemPrompt: systemPrompt,
            temperature: 0.5
        )

        return response.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Quick local text enhancement (basic cleanup)
    func enhanceLocally(_ text: String) -> String {
        var enhanced = text

        // Capitalize first letter
        if let first = enhanced.first {
            enhanced = first.uppercased() + enhanced.dropFirst()
        }

        // Fix common spacing issues
        enhanced = enhanced.replacingOccurrences(of: "  +", with: " ", options: .regularExpression)

        // Trim whitespace
        enhanced = enhanced.trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove trailing periods if present (tasks don't need them)
        if enhanced.hasSuffix(".") {
            enhanced = String(enhanced.dropLast())
        }

        return enhanced
    }

    /// Generates additional context or notes for a task
    func generateNotes(for title: String) async throws -> String {
        isProcessing = true
        defer { isProcessing = false }

        let systemPrompt = """
        You are a task assistant for MindCapture.
        Given a task title, generate helpful notes or context that would be useful.
        Keep it brief (1-2 sentences max).
        If no additional context is needed, return an empty string.

        Respond with ONLY the notes, nothing else.
        """

        let response = try await claudeClient.sendPrompt(
            "Generate notes for: \(title)",
            systemPrompt: systemPrompt,
            temperature: 0.7
        )

        return response.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
