import SwiftUI

@main
struct AnnaParikshaApp: App {
    var body: some Scene {
        WindowGroup {
            AppLaunchRootView()
        }
    }
}

private struct AppLaunchRootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var isShowingLaunchLanding = true

    var body: some View {
        Group {
            if isShowingLaunchLanding {
                LaunchLandingView()
                    .transition(.opacity)
            } else if hasCompletedOnboarding {
                ContentView()
                    .transition(.opacity)
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.22), value: isShowingLaunchLanding)
        .animation(.easeOut(duration: 0.22), value: hasCompletedOnboarding)
        .task {
            await finishLaunchLanding()
        }
    }

    private func finishLaunchLanding() async {
        guard isShowingLaunchLanding else { return }

        try? await Task.sleep(for: .seconds(1.2))
        isShowingLaunchLanding = false
    }
}
