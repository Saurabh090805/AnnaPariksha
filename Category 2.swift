import Foundation

enum Category: String, CaseIterable, Identifiable {
    case dairy = "🐄 Dairy"
    case spices = "🧂 Spices & Powders"
    case vegetables = "🥕 Vegetables"
    case fruits = "🍎 Fruits"
    case staples = "🌾 Staples & Oils"

    var id: String { rawValue }

    var displayName: String {
        String(rawValue.dropFirst(2))
    }
    
    var emoji: String {
        String(rawValue.prefix(1))
    }
}
