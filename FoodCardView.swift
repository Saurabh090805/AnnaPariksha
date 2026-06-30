import SwiftUI

struct FoodCardView: View {
    let foodName: String
    let category: String
    let imageName: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        colorScheme == .dark
                        ? Color.white.opacity(0.08)
                        : Color(uiColor: .systemBackground)
                    )

                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(0)
                    .scaleEffect(imageScale)
                    .shadow(
                        color: colorScheme == .dark ? .black.opacity(0.36) : .black.opacity(0.12),
                        radius: colorScheme == .dark ? 8 : 5,
                        y: 3
                    )
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 132)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(category.uppercased())
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(foodName)
                    .scaledSystemFont(size: 18, weight: .bold, design: .rounded, relativeTo: .headline)
                    .foregroundStyle(.primary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 220)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        colorScheme == .dark
                            ? Color.white.opacity(0.05)
                            : Color.white.opacity(0.25)
                    )
                
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        LinearGradient(
                            colors: colorScheme == .dark
                                ? [.white.opacity(0.2), .white.opacity(0.05), .clear]
                                : [.white.opacity(0.6), .white.opacity(0.2), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.05), lineWidth: 0.5)
        )
        .shadow(
            color: colorScheme == .dark
                ? .black.opacity(0.4)
                : .black.opacity(0.1),
            radius: colorScheme == .dark ? 18 : 14,
            x: 0,
            y: colorScheme == .dark ? 10 : 6
        )
        .contentShape(RoundedRectangle(cornerRadius: 22))
        .accessibilityElement(children: .combine)
    }

    private var imageScale: CGFloat {
        switch imageName {
        case "Apple", "Banana", "Mango", "MustardOil", "Spinach", "Cauliflower", "Brinjal":
            return 1.12
        case "Asafoetida", "BlackPepper", "Butter", "CorianderPowder", "Curd", "GaramMasala",
             "Ghee", "Grapes", "GreenPeas", "Honey", "Milk", "Orange", "Paneer", "Potato",
             "RedChilliPowder", "Rice", "Salt", "Sugar", "TeaPowder", "Tomato",
             "TurmericPowder", "WheatFlour":
            return 1.24
        default:
            return 1.35
        }
    }
}
