import SwiftUI

struct ProtocolSequenceView: View {
    @Environment(\.dismiss) private var dismiss

    let foodItem: AppFoodItem
    let testType: TestType

    private var testConfig: TestConfiguration? {
        testType == .homeDiagnostic ? foodItem.homeTest : foodItem.labTest
    }

    @State private var steps: [ProtocolStep] = []
    @State private var currentStepIndex = 0
    @State private var showResults = false
    @State private var showGuidelines = false
    @Environment(\.colorScheme) private var colorScheme

    private var accent: Color {
        testType == .homeDiagnostic ? .green : .blue
    }

    private var isLaboratoryAnalysis: Bool {
        testType == .laboratory
    }

    private var screenTitle: String {
        testType == .homeDiagnostic ? "At Home Tests" : "Laboratory Analysis"
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    headerSection
                    if isLaboratoryAnalysis {
                        laboratoryDocumentationSection
                    } else {
                        progressSection
                        stepCards

                        if showResults {
                            resultsSection(for: proxy.size.width)
                        } else {
                            actionButton
                        }
                    }
                }
                .padding(.horizontal, proxy.size.width >= 640 ? 28 : 20)
                .padding(.bottom, 40)
                .frame(maxWidth: protocolMaxWidth(for: proxy.size.width))
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(screenTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showGuidelines = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.tint)
                }
                .accessibilityLabel("Safety Guidelines")
                .tint(.primary)
            }
        }
        .sheet(isPresented: $showGuidelines) {
            SafetyGuidelinesSheet()
        }
        .onAppear { loadSteps() }
    }

    private func protocolMaxWidth(for width: CGFloat) -> CGFloat {
        min(width, isLaboratoryAnalysis ? 920 : 820)
    }

    // MARK: - Steps
    private func loadSteps() {
        guard let config = testConfig else { return }
        steps = config.steps.map {
            ProtocolStep(
                number: $0.number,
                title: $0.title,
                instruction: $0.instruction,
                icon: $0.icon,
                isCompleted: false
            )
        }
        currentStepIndex = 0
        showResults = false
    }

    // MARK: - Glass Card
    private func glassCard<Content: View>(
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.16))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(colorScheme == .dark ? 0.2 : 0.3), lineWidth: 0.6)
                    )
            )
            .shadow(
                color: colorScheme == .dark ? .black.opacity(0.35) : .black.opacity(0.08),
                radius: 10,
                y: 4
            )
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
                Text(testConfig?.testName ?? screenTitle)
                    .scaledSystemFont(size: 26, weight: .bold, design: .rounded, relativeTo: .title)
            Text(testConfig?.description ?? "")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(accent.opacity(colorScheme == .dark ? 0.28 : 0.18))
                .frame(height: 0.8)
        }
    }

    private var progressSection: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Progress")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(completedSteps) / \(steps.count)")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(accent)
                }

                ProgressView(
                    value: Double(completedSteps),
                    total: Double(max(steps.count, 1))
                )
                .tint(accent)
            }
        }
    }

    private var completedSteps: Int {
        steps.filter(\.isCompleted).count
    }

    private var stepCards: some View {
        VStack(spacing: 12) {
            ForEach(steps.indices, id: \.self) { index in
                stepCard(step: steps[index], index: index)
            }
        }
    }

    private func stepCard(step: ProtocolStep, index: Int) -> some View {
        let isActive = !isLaboratoryAnalysis && index == currentStepIndex && !showResults

        return HStack(spacing: 16) {
            Circle()
                .fill(isLaboratoryAnalysis ? accent.opacity(0.16) : (step.isCompleted ? accent : Color.gray).opacity(step.isCompleted ? 1.0 : 0.2))
                .frame(width: 44, height: 44)
                .overlay {
                    if step.isCompleted && !isLaboratoryAnalysis {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.white)
                    } else {
                        Text("\(step.number)")
                            .scaledSystemFont(size: 16, weight: .semibold, relativeTo: .body)
                            .foregroundStyle((isActive || isLaboratoryAnalysis) ? accent : .secondary)
                    }
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(step.title).font(.headline)
                Text(step.instruction)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            isActive ? accent : Color.primary.opacity(colorScheme == .dark ? 0.25 : 0.14),
                            lineWidth: isActive ? 1.6 : 0.6
                        )
                        .opacity(isActive ? 1 : 0.5)
                )
        )
    }

    private var laboratoryDocumentationSection: some View {
        VStack(spacing: 16) {
            documentationStepsSection
            laboratoryInterpretationSection
        }
    }

    private var documentationStepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analysis Workflow")
                .font(.title3.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("The workflow below describes the usual report path inside a certified laboratory.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 12) {
                ForEach(steps.indices, id: \.self) { index in
                    LaboratoryWorkflowStepCard(step: steps[index], themeColor: accent)
                }
            }
        }
    }

    private var laboratoryInterpretationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Result Interpretation")
                .font(.title3.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            LabProfileDocumentationCard(
                title: "Acceptable Laboratory Profile",
                subtitle: "Expected / compliant pattern",
                icon: "checkmark.shield.fill",
                themeColor: .green,
                overview: "An acceptable profile means the reported markers are consistent with the natural or permitted composition of \(foodItem.name). The sample does not show the listed warning signatures at the method's reporting level.",
                indicators: testConfig?.normalIndicators ?? [],
                interpretation: "These findings generally support authenticity for the tested markers. They do not prove that every possible contaminant is absent unless the laboratory report specifically includes those analytes.",
                followUp: "Keep the report with batch details, collection date, method name, and laboratory reference number for traceability."
            )

            LabProfileDocumentationCard(
                title: "Flagged\nLaboratory Profile",
                subtitle: "Warning / non-conforming pattern",
                icon: "exclamationmark.triangle.fill",
                themeColor: .red,
                overview: "A flagged profile means one or more markers differ from the expected profile or match known adulteration or contamination indicators. The result should be read against the laboratory's detection limit and applicable safety standard.",
                indicators: testConfig?.abnormalIndicators ?? [],
                interpretation: "These findings may indicate adulteration, substitution, contamination, poor handling, or quality failure. A flagged result should not be treated as a casual observation; it needs formal review.",
                followUp: "Recommended follow-up includes checking the certificate of analysis, confirming sample identity, reviewing batch source, and repeating confirmation through an accredited laboratory if the result affects safety or compliance."
            )
        }
    }

    private var actionButton: some View {
        glassCard(padding: 0) {
            Button {
                executeCurrentStep()
            } label: {
                Text(currentStepIndex == 0 ? "Start Test"
                     : currentStepIndex < steps.count - 1 ? "Next Step" : "Complete Test")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .scaledSystemFont(size: 17, weight: .semibold, relativeTo: .headline)
            }
            .background(accent)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func resultsSection(for width: CGFloat) -> some View {
        VStack(spacing: 24) {
            VStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(accent)
                Text("Analysis Complete")
                    .font(.title2.bold())
                Text("Compare expected vs warning outcomes for this test.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .allowsTightening(true)
            }
            .frame(maxWidth: .infinity)

            if width >= 560 {
                HStack(spacing: 16) {
                    resultCards
                }
            } else {
                VStack(spacing: 16) {
                    resultCards
                }
            }

            HStack(spacing: 12) {
                Button {
                    retryTest()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Test Again")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .scaledSystemFont(size: 17, weight: .semibold, relativeTo: .headline)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.thinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.18), lineWidth: 0.8)
                )
                .foregroundStyle(accent)

                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                        Text("Done")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .scaledSystemFont(size: 17, weight: .semibold, relativeTo: .headline)
                }
                .background(accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    @ViewBuilder
    private var resultCards: some View {
                ResultCard(
                    title: "Normal",
                    icon: "checkmark.shield.fill",
                    indicators: testConfig?.normalIndicators ?? [],
                    themeColor: .green,
                    subtitle: "Expected"
                )
                ResultCard(
                    title: "Adulterated",
                    icon: "exclamationmark.triangle.fill",
                    indicators: testConfig?.abnormalIndicators ?? [],
                    themeColor: .red,
                    subtitle: "Warning"
                )
    }

    private func executeCurrentStep() {
        guard currentStepIndex < steps.count else { showResults = true; return }
        steps[currentStepIndex].isCompleted = true
        currentStepIndex += 1
        if currentStepIndex == steps.count { showResults = true }
    }

    private func retryTest() {
        currentStepIndex = 0
        showResults = false
        steps.indices.forEach { steps[$0].isCompleted = false }
    }
}

// MARK: - Safety Sheet

private struct LaboratoryWorkflowStepCard: View {
    let step: ProtocolStep
    let themeColor: Color

    @State private var isExpanded = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Text("\(step.number)")
                        .scaledSystemFont(size: 16, weight: .bold, relativeTo: .body)
                        .foregroundStyle(themeColor)
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(themeColor.opacity(0.14)))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(step.instruction)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(themeColor)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .padding(.top, 12)
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(step.title) details")
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")

            if isExpanded {
                Divider()
                    .background(themeColor.opacity(0.16))

                workflowDetail(
                    title: "Purpose",
                    text: purposeText
                )

                workflowDetail(
                    title: "Laboratory Review",
                    text: reviewText
                )

                workflowDetail(
                    title: "Report Relevance",
                    text: reportRelevanceText
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.16))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(themeColor.opacity(colorScheme == .dark ? 0.3 : 0.2), lineWidth: 0.8)
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }

    private func workflowDetail(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(themeColor)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var purposeText: String {
        switch normalizedTitle {
        case let title where title.contains("collection") || title.contains("sample"):
            return "Establishes the identity and condition of the submitted sample so the result can be linked to the correct food item, batch, date, and source."
        case let title where title.contains("prep") || title.contains("preparation") || title.contains("dry"):
            return "Converts the sample into a form suitable for instrument reading while reducing interference from moisture, texture, or uneven composition."
        case let title where title.contains("injection") || title.contains("exposure") || title.contains("detection"):
            return "Introduces the prepared sample into the analytical system so measurable signals can be captured under controlled laboratory conditions."
        case let title where title.contains("separation") || title.contains("chromatography"):
            return "Separates components so natural constituents and suspected foreign substances can be evaluated without overlapping signals."
        case let title where title.contains("spectrum") || title.contains("spectrometry") || title.contains("analysis"):
            return "Compares the measured signal pattern with expected reference behaviour and known adulterant or contaminant markers."
        default:
            return "Supports the laboratory's evidence chain by documenting how this stage contributes to the final interpretation."
        }
    }

    private var reviewText: String {
        switch normalizedTitle {
        case let title where title.contains("collection") || title.contains("sample"):
            return "The lab checks sample labeling, container condition, quantity, visible contamination, storage condition, and whether the sample is suitable for the selected method."
        case let title where title.contains("prep") || title.contains("preparation") || title.contains("dry"):
            return "The lab records preparation method, dilution or extraction details, temperature exposure, homogenization, and any factor that may affect recovery or accuracy."
        case let title where title.contains("injection") || title.contains("exposure") || title.contains("detection"):
            return "The lab reviews instrument readiness, calibration status, blank/control response, run sequence, and whether the signal quality is acceptable."
        case let title where title.contains("separation") || title.contains("chromatography"):
            return "The lab evaluates peak separation, retention behaviour, baseline stability, and whether target markers can be distinguished clearly."
        case let title where title.contains("spectrum") || title.contains("spectrometry") || title.contains("analysis"):
            return "The lab compares signal intensity, peak pattern, spectral fingerprint, or measured analyte level against validated references and reporting criteria."
        default:
            return "The lab documents observations, checks consistency with method requirements, and notes anything that could affect interpretation."
        }
    }

    private var reportRelevanceText: String {
        switch normalizedTitle {
        case let title where title.contains("collection") || title.contains("sample"):
            return "Poor identification or unsuitable sample condition can limit confidence in the report, even if the analytical method is correct."
        case let title where title.contains("prep") || title.contains("preparation") || title.contains("dry"):
            return "Preparation quality affects whether adulterants are recoverable and whether the final result reflects the actual sample."
        case let title where title.contains("injection") || title.contains("exposure") || title.contains("detection"):
            return "Stable instrument response supports reliable detection; poor response may require rerun, dilution, or method review."
        case let title where title.contains("separation") || title.contains("chromatography"):
            return "Clear separation improves confidence that the reported marker is real and not caused by overlapping sample components."
        case let title where title.contains("spectrum") || title.contains("spectrometry") || title.contains("analysis"):
            return "This stage usually forms the main evidence for acceptable or flagged status in the final laboratory interpretation."
        default:
            return "The observation is used as supporting evidence when the laboratory decides whether the profile is acceptable or flagged."
        }
    }

    private var normalizedTitle: String {
        step.title.lowercased()
    }
}

private struct LabProfileDocumentationCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let themeColor: Color
    let overview: String
    let indicators: [String]
    let interpretation: String
    let followUp: String

    @State private var isExpanded = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(themeColor)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(themeColor.opacity(0.14)))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(themeColor)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(themeColor)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .padding(.top, 10)
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(title) details")
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")

            if isExpanded {
                Divider()
                    .background(themeColor.opacity(0.16))

                documentationParagraph(title: "Meaning", text: overview)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Detailed Report Indicators")
                        .font(.subheadline.weight(.bold))

                    ForEach(indicators, id: \.self) { indicator in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: themeColor == .green ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(themeColor)
                                .padding(.top, 2)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(indicator)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(detailText(for: indicator))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeColor.opacity(colorScheme == .dark ? 0.12 : 0.08))
                        )
                    }
                }

                documentationParagraph(title: "Interpretation", text: interpretation)
                documentationParagraph(title: "Recommended Documentation", text: followUp)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.16))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(themeColor.opacity(colorScheme == .dark ? 0.32 : 0.22), lineWidth: 0.8)
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }

    private func documentationParagraph(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline.weight(.bold))
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func detailText(for indicator: String) -> String {
        if themeColor == .green {
            return "This marker supports the expected composition because the laboratory profile stays within the normal pattern for this analysis and does not show the listed warning signature."
        }

        return "This marker needs attention because it points to a deviation from the expected profile. It should be reviewed with the method limits, sample identity, and any confirmatory remarks in the lab report."
    }
}

private struct ResultCard: View {
    let title: String
    let icon: String
    let indicators: [String]
    let themeColor: Color
    let subtitle: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(themeColor)
                    Spacer()
                    Text(subtitle)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(themeColor.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(themeColor.opacity(0.15)))
                }
                Text(title)
                    .scaledSystemFont(size: 18, weight: .bold, relativeTo: .headline)
                    .foregroundStyle(themeColor)
            }
            .padding(16)

            Divider()
                .background(themeColor.opacity(0.2))
                .padding(.horizontal, 16)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(indicators, id: \.self) { indicator in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: themeColor == .green ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(themeColor)
                                .font(.system(size: 14))
                                .padding(.top, 2)
                            Text(indicator)
                                .scaledSystemFont(size: 14, weight: .medium, relativeTo: .subheadline)
                                .foregroundStyle(.primary)
                                .lineLimit(nil)
                        }
                    }
                }
                .padding(16)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.white.opacity(colorScheme == .dark ? 0.08 : 0.16))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.2 : 0.3), lineWidth: 0.6)
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }
}

private struct SafetyGuidelinesSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            SafetyGuidelinesView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
        }
        .presentationDetents([.large])
        .presentationBackground(.ultraThinMaterial)
        .tint(.primary)
    }
}

private struct SafetyGuidelinesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text("Safety Guidelines")
                    .scaledSystemFont(size: 28, weight: .bold, design: .rounded, relativeTo: .title)

                disclaimerCard
                chemicalSection
                annaParikshaSafetyCard
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var disclaimerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Critical Disclaimer", systemImage: "exclamationmark.shield")
                .foregroundStyle(.red)
                .font(.headline)

            Text("This app is for educational purposes only. Home checks may highlight possible adulteration concerns, but they are indicative and should be confirmed through accredited laboratories or official food safety guidance before health or compliance decisions.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .liquidGlassCard()
    }

    private var chemicalSection: some View {
        VStack(spacing: 12) {
            guidelineRow(icon: "flask", color: .blue, title: "Glassware Only",
                         text: "Always use clean glass test tubes.")
            guidelineRow(icon: "hand.raised.fill", color: .orange, title: "Skin Protection",
                         text: "Wear gloves when handling acids.")
            guidelineRow(icon: "eye.fill", color: .purple, title: "Eye Safety",
                         text: "Never sniff chemicals directly.")
        }
    }

    private func guidelineRow(icon: String, color: Color, title: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(.white.opacity(0.8), in: Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.headline)
                Text(text).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .liquidGlassCard()
    }

    private var annaParikshaSafetyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("AnnaPariksha Safety Path", systemImage: "checkmark.shield")
                .foregroundStyle(.green)
                .font(.headline)

            Text("Use proper tools, protect skin and eyes, and confirm findings with certified laboratories.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .liquidGlassCard()
    }
}

// MARK: - Liquid Glass (FIXED WIDTH)

private extension View {
    func liquidGlassCard() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.primary.opacity(0.18), lineWidth: 0.6)
                    )
            )
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }
}
