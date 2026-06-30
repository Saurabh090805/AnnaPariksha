import SwiftUI

struct ScanSafetyReportView: View {
    let report: IngredientSafetyReport
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Important") {
                    Label(
                        "Educational label screening only. AnnaPariksha highlights possible ingredient, nutrition, allergen, or adulteration concerns for careful review. It does not certify food as safe or unsafe; confirm serious concerns with official guidance, package warnings, or accredited laboratory testing.",
                        systemImage: "info.circle.fill"
                    )
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                }

                Section("Label Summary") {
                    Text(report.summary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        Text("Screening result")
                        Spacer()
                        Text(report.decision.rawValue)
                            .font(.headline)
                            .foregroundStyle(verdictColor(report.decision))
                            .multilineTextAlignment(.trailing)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let confidence = report.confidence {
                        HStack {
                            Text("Confidence")
                            Spacer()
                            Text("\(Int((confidence * 100).rounded()))%")
                                .font(.headline)
                                .foregroundStyle(confidence < 0.65 ? .orange : .secondary)
                        }
                    }

                    HStack {
                        Text("Review score")
                        Spacer()
                        Text("\(report.riskScore)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Nutrients found")
                        Spacer()
                        Text("\(report.nutrientCount)")
                            .foregroundStyle(.secondary)
                    }
                }

                if !report.reasons.isEmpty {
                    Section("Why") {
                        ForEach(report.reasons, id: \.self) { reason in
                            Label(reason, systemImage: "checklist")
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                componentSection("Ingredients Detected", report.detectedIngredients)
                componentSection("Additives Found", report.detectedAdditives)

                nutritionSection("Macronutrients", report.nutritionMetrics.filter(isMacro))
                nutritionSection("Minerals", report.nutritionMetrics.filter(isMineral))
                nutritionSection("Vitamins", report.nutritionMetrics.filter(isVitamin))

                let visibleMicronutrients = report.micronutrients.filter { $0.status != "Not detected" }
                if !visibleMicronutrients.isEmpty {
                    Section("Vitamins & Minerals") {
                        ForEach(visibleMicronutrients) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .top) {
                                    Text(item.name)
                                        .font(.headline)
                                    Spacer()
                                    Text(item.status)
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(micronutrientColor(item.status).opacity(0.15))
                                        .foregroundStyle(micronutrientColor(item.status))
                                        .clipShape(Capsule())
                                }
                                Text(item.role)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }

                if !report.detectedAllergens.isEmpty {
                    Section("Allergy Warning") {
                        Label(
                            "Contains possible allergens: \(report.detectedAllergens.joined(separator: ", ")). Avoid if you are allergic to these ingredients.",
                            systemImage: "exclamationmark.octagon.fill"
                        )
                        .foregroundStyle(.red)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if !report.warnings.isEmpty {
                    Section("Review Notes") {
                        ForEach(report.warnings, id: \.self) {
                            Label($0, systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                Section("Suggested Next Step") {
                    Text(report.finalAdvice)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }

                SourceLinksListSection()
            }
            .navigationTitle("Label Screening Report")
            .onAppear {
                AccessibilitySupport.announce("Label screening report. Result: \(report.decision.rawValue). \(report.summary)")
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        Haptics.success()
                        dismiss()
                    }
                    .tint(.primary)
                    .accessibilityLabel("Done")
                    .accessibilityHint("Closes label screening report")
                    .accessibilityInputLabels(["Done", "Tap Done", "Close Report", "Back to Home"])
                }
            }
        }
    }


    @ViewBuilder
    private func componentSection(_ title: String, _ components: [FoodComponent]) -> some View {
        if !components.isEmpty {
            Section(title) {
                ForEach(components) { component in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            Text(component.name)
                                .font(.headline)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .layoutPriority(1)

                            Spacer()

                            Text(component.category.rawValue)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(componentColor(component.riskLevel).opacity(0.15))
                                .foregroundStyle(componentColor(component.riskLevel))
                                .clipShape(Capsule())
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.trailing)
                        }

                        Text(component.purpose)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(component.advice)
                            .font(.subheadline)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }


    @ViewBuilder
    private func nutritionSection(_ title: String, _ metrics: [NutritionMetric]) -> some View {
        if !metrics.isEmpty {
            Section(title) {
                ForEach(metrics) { n in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            Text(n.name)
                                .font(.headline)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .layoutPriority(1)

                            Spacer()

                            Text(label(n.status))
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(color(n.status).opacity(0.15))
                                .foregroundStyle(color(n.status))
                                .clipShape(Capsule())
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.trailing)
                        }

                        if let s = n.perServe {
                            Text("Per serve: \(s)")
                                .foregroundStyle(.secondary)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        if let p = n.per100g {
                            Text("Per 100g: \(p)")
                                .foregroundStyle(.secondary)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        if let dv = n.dvPercent {
                            Text("%DV: \(dv)")
                                .foregroundStyle(.secondary)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        if let rda = n.rdaPercent {
                            Text("%RDA: \(rda)")
                                .foregroundStyle(.secondary)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }


    private func isMacro(_ n: NutritionMetric) -> Bool {
        [
            "Energy",
            "Protein",
            "Carbohydrate",
            "Total Sugars",
            "Added Sugar",
            "Total Fat",
            "Saturated Fat",
            "Trans Fat",
            "Dietary Fibre",
            "Cholesterol"
        ].contains(n.name)
    }

    private func isMineral(_ n: NutritionMetric) -> Bool {
        [
            "Sodium",
            "Potassium",
            "Calcium",
            "Magnesium",
            "Iron",
            "Zinc",
            "Iodine",
            "Selenium",
            "Phosphorus",
            "Manganese",
            "Copper",
            "Chloride",
            "Chromium",
            "Molybdenum"
        ].contains(n.name)
    }

    private func isVitamin(_ n: NutritionMetric) -> Bool {
        let name = n.name.lowercased()
        if name.starts(with: "vitamin") { return true }
        return [
            "thiamin",
            "riboflavin",
            "niacin",
            "vitamin b6",
            "folate",
            "vitamin b12",
            "biotin",
            "pantothenic acid",
            "choline"
        ].contains(name)
    }


    private func verdictColor(_ d: OverallFoodDecision) -> Color {
        d == .safeToConsume ? .green :
        d == .consumeOccasionally ? .orange : .red
    }

    private func color(_ s: String) -> Color {
        s == "NOT SAFE" ? .red :
        s == "LIMIT" ? .orange :
        s == "LOW" ? .secondary : .green
    }

    private func label(_ s: String) -> String {
        s == "NOT SAFE" ? "HIGH" :
        s == "LIMIT" ? "LIMIT" :
        s == "GOOD" ? "GOOD" :
        s == "LOW" ? "LOW" : "OK"
    }

    private func componentColor(_ risk: RiskLevel) -> Color {
        risk == .avoid ? .red :
        risk == .limit ? .orange : .green
    }

    private func micronutrientColor(_ status: String) -> Color {
        status == "High / limit" ? .orange :
        status == "Not detected" ? .secondary : .green
    }
}

struct SourceLink: Identifiable {
    let id = UUID()
    let title: String
    let organization: String
    let url: URL
}

let annaParikshaSourceLinks: [SourceLink] = [
    SourceLink(
        title: "Detect Adulteration with Rapid Test (DART)",
        organization: "Food Safety and Standards Authority of India",
        url: URL(string: "https://fssai.gov.in/upload/uploadfiles/files/DART.pdf")!
    ),
    SourceLink(
        title: "Food Safety and Standards Regulations",
        organization: "Food Safety and Standards Authority of India",
        url: URL(string: "https://www.fssai.gov.in/cms/food-safety-and-standards-regulations.php")!
    ),
    SourceLink(
        title: "Daily Value on Nutrition and Supplement Facts Labels",
        organization: "U.S. Food and Drug Administration",
        url: URL(string: "https://www.fda.gov/food/nutrition-facts-label/daily-value-nutrition-and-supplement-facts-labels")!
    ),
    SourceLink(
        title: "Food Allergies",
        organization: "U.S. Food and Drug Administration",
        url: URL(string: "https://www.fda.gov/food/nutrition-food-labeling-and-critical-foods/food-allergies")!
    ),
    SourceLink(
        title: "Healthy Diet",
        organization: "World Health Organization",
        url: URL(string: "https://www.who.int/news-room/fact-sheets/detail/healthy-diet")!
    )
]

struct SourceLinksListSection: View {
    var body: some View {
        Section("Sources & Citations") {
            ForEach(annaParikshaSourceLinks) { source in
                Link(destination: source.url) {
                    SourceLinkRow(source: source)
                }
            }
        }
    }
}

struct SourceLinksCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "book.closed.fill")
                    .foregroundStyle(.blue)
                Text("Sources & Citations")
                    .font(.title3.weight(.bold))
            }
            .accessibilityAddTraits(.isHeader)

            Text("Food quality notes, nutrition thresholds, and allergen guidance are based on these public references.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                ForEach(annaParikshaSourceLinks) { source in
                    Link(destination: source.url) {
                        SourceLinkRow(source: source)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

struct SourceLinkRow: View {
    let source: SourceLink

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "link")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 22, height: 22)

            VStack(alignment: .leading, spacing: 3) {
                Text(source.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(source.organization)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Image(systemName: "arrow.up.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(source.title), \(source.organization)")
        .accessibilityHint("Opens citation source")
    }
}
