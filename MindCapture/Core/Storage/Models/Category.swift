//
//  Category.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Category {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var isDefault: Bool
    var createdAt: Date

    init(name: String, icon: String, colorHex: String, isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.isDefault = isDefault
        self.createdAt = Date()
    }

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    // Default categories
    static let defaultCategories: [Category] = [
        Category(name: "Health", icon: "heart.fill", colorHex: "#FF3B30", isDefault: true),
        Category(name: "Family", icon: "figure.2.and.child.holdinghands", colorHex: "#FF9500", isDefault: true),
        Category(name: "Work", icon: "briefcase.fill", colorHex: "#007AFF", isDefault: true),
        Category(name: "Finance", icon: "dollarsign.circle.fill", colorHex: "#34C759", isDefault: true),
        Category(name: "Learning", icon: "book.fill", colorHex: "#5856D6", isDefault: true),
        Category(name: "Creative", icon: "paintbrush.fill", colorHex: "#AF52DE", isDefault: true),
        Category(name: "Travel", icon: "airplane", colorHex: "#00C7BE", isDefault: true),
        Category(name: "Shopping", icon: "cart.fill", colorHex: "#FF2D55", isDefault: true),
        Category(name: "Tech", icon: "laptopcomputer", colorHex: "#5AC8FA", isDefault: true),
        Category(name: "Other", icon: "star.fill", colorHex: "#8E8E93", isDefault: true)
    ]
}

// Color extension for hex support
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }

    func toHex() -> String {
        #if os(macOS)
        guard let components = NSColor(self).cgColor.components else { return "#000000" }
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        return String(format: "#%02X%02X%02X", r, g, b)
        #else
        guard let components = UIColor(self).cgColor.components else { return "#000000" }
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        return String(format: "#%02X%02X%02X", r, g, b)
        #endif
    }
}
