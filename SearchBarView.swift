import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @FocusState.Binding var isFocused: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 8) {
            
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                
                TextField("Find food items...", text: $searchText)
                    .focused($isFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .scaledSystemFont(size: 17, relativeTo: .body)
                    .accessibilityLabel("Search")
                    .accessibilityHint("Search ingredients")
                    .accessibilityInputLabels(["Search", "Tap Search", "Find Food"])
                
                if !searchText.isEmpty {
                    Button {
                        withAnimation(.spring(response: 0.25)) {
                            searchText = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.secondary.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity.combined(with: .scale))
                    .accessibilityLabel("Clear")
                    .accessibilityHint("Clears search text")
                    .accessibilityInputLabels(["Clear", "Tap Clear", "Clear Search"])
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.thinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.white.opacity(colorScheme == .dark ? 0.08 : 0.32))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                .white.opacity(colorScheme == .dark ? 0.22 : 0.58),
                                lineWidth: 0.75
                            )
                    }
                    .shadow(
                        color: colorScheme == .dark ? .black.opacity(0.25) : .black.opacity(0.06),
                        radius: 8,
                        y: 3
                    )
            }
            
            if isFocused {
                Button {
                    Haptics.lightImpact()
                    withAnimation(.spring(response: 0.25)) {
                        searchText = ""
                    }
                    isFocused = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 36, height: 36)
                        .background {
                            Circle()
                                .fill(.thinMaterial)
                                .overlay {
                                    Circle()
                                        .fill(.white.opacity(colorScheme == .dark ? 0.08 : 0.28))
                                }
                                .overlay {
                                    Circle()
                                        .stroke(
                                            .white.opacity(colorScheme == .dark ? 0.22 : 0.58),
                                            lineWidth: 0.75
                                        )
                                }
                                .shadow(
                                    color: colorScheme == .dark ? .black.opacity(0.22) : .black.opacity(0.06),
                                    radius: 6,
                                    y: 2
                                )
                        }
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
                .accessibilityLabel("Close Search")
                .accessibilityHint("Dismisses keyboard and clears search")
                .accessibilityInputLabels(["Close Search", "Tap Close Search", "Dismiss Keyboard"])
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isFocused)
        .animation(.spring(response: 0.25), value: searchText.isEmpty)
    }
}
