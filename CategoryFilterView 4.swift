import SwiftUI

struct CategoryFilterView: View {
    @Binding var selectedCategory: Category?
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(
                    icon: "square.grid.2x2.fill",
                    emoji: nil,
                    title: "All",
                    isSelected: selectedCategory == nil
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedCategory = nil
                    }
                }
                
                ForEach(Category.allCases) { category in
                    FilterChip(
                        icon: nil,
                        emoji: category.emoji,
                        title: category.displayName,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .accessibilityLabel("Ingredient categories")
        .accessibilityHint("Swipe left or right to browse categories")
    }
}

struct FilterChip: View {
    let icon: String?
    let emoji: String?
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    private let scanAccent = Color(uiColor: .systemGreen)
    
    var body: some View {
        Button {
            Haptics.lightImpact()
            action()
        } label: {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                } else if let emoji = emoji {
                    Text(emoji)
                        .font(.system(size: 14))
                }
                
                Text(title)
                    .font(.subheadline.weight(isSelected ? .semibold : .medium))
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(chipBackground)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .accessibilityLabel(title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityHint("Filters ingredient list")
        .accessibilityInputLabels([title, "Tap \(title)", "Open \(title)"])
    }
    
    @ViewBuilder
    private var chipBackground: some View {
        if isSelected {
            Capsule(style: .continuous)
                .fill(scanAccent)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(.white.opacity(colorScheme == .dark ? 0.22 : 0.3), lineWidth: 0.5)
                )
                .shadow(
                    color: scanAccent.opacity(colorScheme == .dark ? 0.45 : 0.28),
                    radius: 6,
                    y: 3
                )
        } else {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule(style: .continuous)
                        .fill(colorScheme == .dark ? .white.opacity(0.05) : .white.opacity(0.25))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(
                            .white.opacity(colorScheme == .dark ? 0.15 : 0.4),
                            lineWidth: 0.5
                        )
                )
                .shadow(
                    color: colorScheme == .dark ? .black.opacity(0.4) : .black.opacity(0.1),
                    radius: 6,
                    y: 2
                )
        }
    }
}
