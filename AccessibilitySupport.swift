import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

enum AccessibilitySupport {
    @MainActor static func announce(_ message: String) {
        #if canImport(UIKit)
        guard UIAccessibility.isVoiceOverRunning else { return }
        UIAccessibility.post(notification: .announcement, argument: message)
        #endif
    }
}

struct ScaledSystemFontModifier: ViewModifier {
    @ScaledMetric private var scaledSize: CGFloat

    private let weight: Font.Weight
    private let design: Font.Design

    init(
        size: CGFloat,
        weight: Font.Weight = .regular,
        design: Font.Design = .default,
        relativeTo textStyle: Font.TextStyle = .body
    ) {
        _scaledSize = ScaledMetric(wrappedValue: size, relativeTo: textStyle)
        self.weight = weight
        self.design = design
    }

    func body(content: Content) -> some View {
        content.font(.system(size: scaledSize, weight: weight, design: design))
    }
}

extension View {
    func scaledSystemFont(
        size: CGFloat,
        weight: Font.Weight = .regular,
        design: Font.Design = .default,
        relativeTo textStyle: Font.TextStyle = .body
    ) -> some View {
        modifier(
            ScaledSystemFontModifier(
                size: size,
                weight: weight,
                design: design,
                relativeTo: textStyle
            )
        )
    }
}
