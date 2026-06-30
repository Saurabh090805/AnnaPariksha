import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    let onStart: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.green.opacity(0.18),
                    Color.green.opacity(0.05),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { proxy in
                VStack(spacing: 0) {
                    Spacer()

                    TabView(selection: $currentPage) {
                        WelcomePage()
                            .tag(0)

                        FeaturesPage()
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: min(560, max(460, proxy.size.height * 0.68)))

                    Spacer()

                    VStack(spacing: 14) {
                        Button(action: advanceOrStart) {
                            Text(currentPage == 0 ? "Continue" : "Start")
                                .scaledSystemFont(size: 17, weight: .semibold, relativeTo: .headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .shadow(color: .green.opacity(0.22), radius: 8, x: 0, y: 3)
                        }
                        .frame(maxWidth: 440)
                        .padding(.horizontal, 32)
                        .accessibilityLabel(currentPage == 0 ? "Continue" : "Start")
                        .accessibilityHint(currentPage == 0 ? "Shows the next onboarding page" : "Opens the main app")
                        .accessibilityInputLabels(currentPage == 0 ? ["Continue", "Next", "Tap Continue"] : ["Start", "Tap Start", "Open App"])

                        if currentPage == 0 {
                            LiquidGlassPageControl(currentPage: $currentPage)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: currentPage)
                    .onChange(of: currentPage) { _, _ in
                        Haptics.lightImpact()
                    }
                    .padding(.bottom, proxy.size.height >= 700 ? 50 : 28)
                }
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func advanceOrStart() {
        Haptics.mediumImpact()
        if currentPage == 0 {
            currentPage = 1
        } else {
            onStart()
        }
    }
}

struct LiquidGlassPageControl: View {
    @Binding var currentPage: Int
    let totalPages = 2

    private var pageStatus: String {
        "Page \(currentPage + 1) of \(totalPages)"
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? .white : .gray.opacity(0.55))
                    .frame(
                        width: currentPage == index ? 8 : 6,
                        height: currentPage == index ? 8 : 6
                    )
            }
        }
        .frame(height: 36)
        .frame(maxWidth: 74)
        .background(
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(Color.white.opacity(0.28), lineWidth: 0.5)
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        .padding(.horizontal, 24)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Onboarding page")
        .accessibilityValue(pageStatus)
    }
}

struct WelcomePage: View {
    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {
                Text("FOOD LABEL SCREENING")
                    .scaledSystemFont(size: 13, weight: .semibold, relativeTo: .caption)
                    .tracking(2.5)
                    .foregroundColor(.green)

                Text("Food Insight")
                    .scaledSystemFont(size: 48, weight: .bold, design: .rounded, relativeTo: .largeTitle)
                    .multilineTextAlignment(.center)

                Text("Scan packaged food labels for educational ingredient and nutrition notes. Results are not a safety certification.")
                    .scaledSystemFont(size: 18, relativeTo: .body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 40)
                    .accessibilityLabel("Scan packaged food labels for educational ingredient and nutrition notes. Results are not a safety certification.")
            }

            Spacer()
        }
    }
}

struct FeaturesPage: View {
    var body: some View {
        VStack {
            VStack(spacing: 12) {
                Text("HOW IT WORKS")
                    .scaledSystemFont(size: 13, weight: .semibold, relativeTo: .caption)
                    .tracking(2.5)
                    .foregroundColor(.green)

                Text("Clarity at Every Step")
                    .scaledSystemFont(size: 30, weight: .bold, design: .rounded, relativeTo: .title)
                    .multilineTextAlignment(.center)

                Text("Understand label signals with simple screening notes and guidance to verify important concerns.")
                    .scaledSystemFont(size: 16, relativeTo: .body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.top, 50)

            VStack(spacing: 16) {

                FeatureRow(
                    icon: "camera.viewfinder",
                    title: "Label Screening Report",
                    text: "Scan food labels to review nutrition and ingredient signals."
                )

                FeatureRow(
                    icon: "house",
                    title: "At-Home Screening",
                    text: "Simple educational checks that may suggest when further verification is needed."
                )

                FeatureRow(
                    icon: "flask",
                    title: "Laboratory Insight",
                    text: "Understand how accredited testing can confirm food quality concerns."
                )
            }
            .padding(.top, 32)
            .padding(.horizontal, 20)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("App features")

            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.green)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .scaledSystemFont(size: 16, weight: .semibold, relativeTo: .headline)

                Text(text)
                    .scaledSystemFont(size: 14, relativeTo: .subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.8)
                )
        )
        .shadow(color: .black.opacity(0.03), radius: 16, x: 0, y: 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(text)
    }
}
