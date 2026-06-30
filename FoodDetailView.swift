import SwiftUI

struct FoodDetailView: View {
    @State private var selectedTestType: TestType?
    @State private var navigateToProtocol = false
    
    let foodItem: AppFoodItem
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    private var risks: [Risk] {
        return getRisks(for: foodItem.name)
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        headerSection

                        VStack(spacing: 28) {
                            educationalNotice
                            if !risks.isEmpty {
                                risksSection
                            }
                            proceduresSection
                            SourceLinksCard()
                        }
                        .padding(.horizontal, proxy.size.width >= 640 ? 28 : 20)
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                    }
                    .frame(maxWidth: detailMaxWidth(for: proxy.size.width))
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle(foodItem.category.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToProtocol) {
            if let testType = selectedTestType {
                ProtocolSequenceView(foodItem: foodItem, testType: testType)
            }
        }
        .onAppear {
            let availableProcedures = [foodItem.homeTest, foodItem.labTest].compactMap { $0 }.count
            AccessibilitySupport.announce("\(foodItem.name). \(risks.count) risks. \(availableProcedures) procedures available.")
        }
    }

    private func detailMaxWidth(for width: CGFloat) -> CGFloat {
        min(width, 820)
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 40)
            
            Image(foodItem.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 16,
                    x: 0,
                    y: 6
                )
                .accessibilityHidden(true)
            
            Text(foodItem.name)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .accessibilityAddTraits(.isHeader)
            
            Capsule()
                .fill(.primary.opacity(0.15))
                .frame(width: 60, height: 4)
                .accessibilityHidden(true)
            
            Spacer(minLength: 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }
    
    private var risksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Possible Quality Signals",
                accentColor: .red
            )
            
            VStack(spacing: 12) {
                ForEach(risks) { risk in
                    RiskCard(risk: risk)
                }
            }
        }
    }

    private var educationalNotice: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.blue)
                .padding(.top, 2)

            Text("Educational reference only. AnnaPariksha highlights possible adulteration or label concerns so you can inspect the food, packaging, and ingredients more carefully. It does not certify a product as safe or unsafe; confirm serious concerns through official guidance or accredited laboratory testing.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(colorScheme == .dark ? 0.14 : 0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.18), lineWidth: 0.8)
        )
        .accessibilityElement(children: .combine)
    }
    
    private var proceduresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Procedures")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
            
            VStack(spacing: 12) {
                ProcedureButton(
                    icon: "house.fill",
                    title: "At Home Tests",
                    subtitle: "Quick home checks",
                    iconColor: .green,
                    isAvailable: foodItem.homeTest != nil,
                    voiceCommands: ["At home tests", "Open at home tests", "Start home test"],
                    action: {
                        selectedTestType = .homeDiagnostic
                        navigateToProtocol = true
                    }
                )
                
                ProcedureButton(
                    icon: "testtube.2",
                    title: "Laboratory Analysis",
                    subtitle: "Detailed lab checks",
                    iconColor: .blue,
                    isAvailable: foodItem.labTest != nil,
                    voiceCommands: ["Laboratory analysis", "Open laboratory analysis", "Lab review"],
                    action: {
                        selectedTestType = .laboratory
                        navigateToProtocol = true
                    }
                )
            }
        }
    }
    
    private func sectionHeader(title: String, accentColor: Color) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(accentColor)
                .frame(width: 4, height: 22)
            
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
        }
    }
}

struct RiskCard: View {
    let risk: Risk
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.red.opacity(colorScheme == .dark ? 0.2 : 0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.red)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(risk.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(risk.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .layoutPriority(1)
            
            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(colorScheme == .dark ? .white.opacity(0.05) : .white.opacity(0.24))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(colorScheme == .dark ? 0.18 : 0.45), lineWidth: 0.6)
        )
        .shadow(
            color: colorScheme == .dark ? .black.opacity(0.35) : .black.opacity(0.08),
            radius: 10,
            y: 4
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(risk.title)
        .accessibilityValue(risk.description)
    }
}

struct ProcedureButton: View {
    let icon: String
    let title: String
    let subtitle: String?
    let iconColor: Color
    let isAvailable: Bool
    let voiceCommands: [String]
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: {
            Haptics.lightImpact()
            action()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(iconColor)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(isAvailable ? .primary : .secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .layoutPriority(1)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary.opacity(colorScheme == .dark ? 0.4 : 0.5))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? .white.opacity(0.05) : .white.opacity(0.24))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(colorScheme == .dark ? 0.18 : 0.45), lineWidth: 0.6)
            )
            .shadow(
                color: colorScheme == .dark ? .black.opacity(0.35) : .black.opacity(0.08),
                radius: 10,
                y: 4
            )
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
        .opacity(isAvailable ? 1 : 0.45)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(isAvailable ? "Available" : "Unavailable")
        .accessibilityHint(
            isAvailable
            ? "Opens \(title.lowercased()) steps"
            : "Not available for this ingredient"
        )
        .accessibilityInputLabels([title, "Tap \(title)", "Open \(title)"] + voiceCommands)
    }
}
