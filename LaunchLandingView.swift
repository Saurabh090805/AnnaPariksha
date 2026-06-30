import SwiftUI

struct LaunchLandingView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.green.opacity(0.22),
                    Color(.systemBackground),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("AnnaPariksha")
                    .scaledSystemFont(size: 42, weight: .bold, design: .rounded, relativeTo: .largeTitle)
                    .foregroundStyle(.primary)
                    .accessibilityAddTraits(.isHeader)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("AnnaPariksha")
        }
    }
}
