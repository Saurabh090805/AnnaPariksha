import Foundation

struct ProtocolStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let instruction: String
    let icon: String
    var isCompleted: Bool = false
}
