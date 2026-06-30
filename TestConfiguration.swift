import Foundation

struct TestConfiguration {
    let testName: String
    let description: String
    let steps: [ProtocolStepData]
    let normalIndicators: [String]
    let abnormalIndicators: [String]
}

struct ProtocolStepData: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let instruction: String
    let icon: String
}
