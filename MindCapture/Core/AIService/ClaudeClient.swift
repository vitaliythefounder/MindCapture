//
//  ClaudeClient.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import Foundation

enum ClaudeError: Error {
    case invalidAPIKey
    case networkError(Error)
    case invalidResponse
    case apiError(String)
    case decodingError(Error)
}

struct ClaudeMessage: Codable {
    let role: String
    let content: String
}

struct ClaudeRequest: Codable {
    let model: String
    let messages: [ClaudeMessage]
    let max_tokens: Int
    let temperature: Double?
}

struct ClaudeResponse: Codable {
    let id: String
    let type: String
    let role: String
    let content: [ContentBlock]
    let model: String
    let stop_reason: String?
    let usage: Usage?

    struct ContentBlock: Codable {
        let type: String
        let text: String?
    }

    struct Usage: Codable {
        let input_tokens: Int
        let output_tokens: Int
    }
}

@MainActor
class ClaudeClient: ObservableObject {
    private let endpoint = Constants.claudeAPIEndpoint
    private let apiVersion = Constants.apiVersion
    @Published var isProcessing = false
    @Published var lastError: ClaudeError?

    private var apiKey: String
    private var model: String

    init(apiKey: String = "", model: String = Constants.defaultClaudeModel) {
        self.apiKey = apiKey
        self.model = model
    }

    func updateConfiguration(apiKey: String, model: String) {
        self.apiKey = apiKey
        self.model = model
    }

    /// Sends a prompt to Claude API and returns the response
    func sendPrompt(_ prompt: String, systemPrompt: String? = nil, temperature: Double = 0.7) async throws -> String {
        guard !apiKey.isEmpty else {
            throw ClaudeError.invalidAPIKey
        }

        isProcessing = true
        defer { isProcessing = false }

        var messages: [ClaudeMessage] = []

        if let systemPrompt = systemPrompt {
            messages.append(ClaudeMessage(role: "system", content: systemPrompt))
        }

        messages.append(ClaudeMessage(role: "user", content: prompt))

        let request = ClaudeRequest(
            model: model,
            messages: messages,
            max_tokens: 1024,
            temperature: temperature
        )

        guard let url = URL(string: endpoint) else {
            throw ClaudeError.invalidResponse
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(apiVersion, forHTTPHeaderField: "anthropic-version")
        urlRequest.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            throw ClaudeError.decodingError(error)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ClaudeError.invalidResponse
            }

            if httpResponse.statusCode != 200 {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw ClaudeError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
            }

            let claudeResponse = try JSONDecoder().decode(ClaudeResponse.self, from: data)

            guard let text = claudeResponse.content.first?.text else {
                throw ClaudeError.invalidResponse
            }

            return text
        } catch let error as ClaudeError {
            lastError = error
            throw error
        } catch {
            lastError = .networkError(error)
            throw ClaudeError.networkError(error)
        }
    }

    /// Test API key validity
    func testAPIKey() async -> Bool {
        do {
            _ = try await sendPrompt("Hello", temperature: 0.0)
            return true
        } catch {
            return false
        }
    }
}
