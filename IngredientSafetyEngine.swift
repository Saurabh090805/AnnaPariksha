import Foundation

let rdaTable: [String: (value: Double, unit: String)] = [
    "energy": (2000, "kcal"),
    "total fat": (67, "g"),
    "saturated fat": (22, "g"),
    "trans fat": (2, "g"),
    "total sugars": (50, "g"),
    "added sugar": (50, "g"),
    "sodium": (2000, "mg"),
    "cholesterol": (300, "mg"),
    "dietary fibre": (30, "g")
]

let nutrientAlias: [String: String] = [
    "calories": "energy",
    "kcal": "energy",
    "kilocalories": "energy",
    "kj": "energy",
    "total fat": "total fat",
    "fat": "total fat",
    "total carbohydrate": "carbohydrate",
    "carbs": "carbohydrate",
    "salt": "sodium",
    "fiber": "dietary fibre",
    "fibre": "dietary fibre",
    "dietary fiber": "dietary fibre",
    "added sugars": "added sugar",
    "sugar": "total sugars",
    "sugars": "total sugars",
    "total sugar": "total sugars",
    "total sugars": "total sugars",
    "cholesterol": "cholesterol",
    "protein": "protein",
    "vitamin a": "vitamin a",
    "vitamin c": "vitamin c",
    "vitamin d": "vitamin d",
    "vitamin e": "vitamin e",
    "vitamin k": "vitamin k",
    "calcium": "calcium",
    "iron": "iron",
    "potassium": "potassium",
    "magnesium": "magnesium",
    "zinc": "zinc"
]

let supportedNutrients: Set<String> = [
    "energy",
    "protein",
    "carbohydrate",
    "total sugars",
    "added sugar",
    "total fat",
    "saturated fat",
    "trans fat",
    "sodium",
    "cholesterol",
    "dietary fibre",
    "vitamin a",
    "vitamin c",
    "vitamin d",
    "vitamin e",
    "vitamin k",
    "calcium",
    "iron",
    "potassium",
    "magnesium",
    "zinc"
]

private let nutritionKeywords: [String] = [
    "nutrition", "serving size", "amount per serving",
    "energy", "calories", "protein", "carbohydrate", "total carbohydrate",
    "total fat", "saturated fat", "trans fat", "cholesterol", "sodium",
    "total sugars", "sugars", "added sugar", "added sugars",
    "dietary fibre", "dietary fiber",
    "vitamin a", "vitamin c", "vitamin d", "vitamin e", "vitamin k",
    "calcium", "iron", "potassium", "magnesium", "zinc"
]

private let riskNutrients: Set<String> = [
    "sodium",
    "added sugar",
    "total sugars",
    "saturated fat",
    "trans fat",
    "cholesterol"
]

private let beneficialNutrients: Set<String> = [
    "protein",
    "dietary fibre",
    "vitamin a",
    "vitamin c",
    "vitamin d",
    "vitamin e",
    "vitamin k",
    "calcium",
    "iron",
    "potassium",
    "magnesium",
    "zinc"
]

private struct ParsedCandidate {
    let nutrient: String
    let token: String
    let perServeValue: Double?
    let per100gValue: Double?
    let unit: String?
    let dvPercent: Double?
    let rdaPercent: Double?
}

private struct Micronutrient {
    let name: String
    let aliases: [String]
    let role: String
}

private let componentDatabase: [FoodComponent] = [
    FoodComponent(
        name: "Wheat Flour",
        aliases: ["wheat flour", "atta", "maida", "refined wheat flour"],
        category: .ingredient,
        purpose: "Common cereal flour used as the base of many packaged foods.",
        riskLevel: .safe,
        explanation: "Usually safe for most people, but it contains gluten.",
        advice: "Avoid if you have wheat allergy or gluten sensitivity."
    ),
    FoodComponent(
        name: "Sugar",
        aliases: ["sugar", "sucrose", "cane sugar", "liquid glucose", "glucose syrup", "fructose syrup"],
        category: .ingredient,
        purpose: "Sweetener used for taste and texture.",
        riskLevel: .limit,
        explanation: "Frequent intake of sugary packaged food can increase overall sugar consumption.",
        advice: "Consume in limit, especially when the nutrition panel also shows high sugar."
    ),
    FoodComponent(
        name: "Palm Oil",
        aliases: ["palm oil", "palmolein", "palm olein", "vegetable fat", "edible vegetable fat"],
        category: .ingredient,
        purpose: "Fat source used for texture, frying stability, and shelf life.",
        riskLevel: .limit,
        explanation: "Common in processed snacks and bakery foods.",
        advice: "Limit frequent intake of highly processed foods containing refined fats."
    ),
    FoodComponent(
        name: "Salt",
        aliases: ["salt", "iodised salt", "iodized salt"],
        category: .ingredient,
        purpose: "Adds taste and helps preservation.",
        riskLevel: .limit,
        explanation: "Salt contributes to sodium intake.",
        advice: "Check sodium values and consume carefully if sodium is high."
    ),
    FoodComponent(
        name: "Sodium Benzoate",
        aliases: ["sodium benzoate", "ins 211", "ins211", "e211", "e 211", "preservative 211"],
        category: .preservative,
        purpose: "Used to prevent bacterial and fungal growth in packaged foods.",
        riskLevel: .limit,
        explanation: "A commonly used preservative in beverages, sauces, and processed foods.",
        advice: "Allowed in regulated limits, but frequent intake of highly processed foods should be limited."
    ),
    FoodComponent(
        name: "Potassium Sorbate",
        aliases: ["potassium sorbate", "ins 202", "ins202", "e202", "e 202", "preservative 202"],
        category: .preservative,
        purpose: "Helps prevent mould and yeast growth.",
        riskLevel: .limit,
        explanation: "Often used in cheese, sauces, bakery fillings, and beverages.",
        advice: "Consume occasionally when found in processed foods."
    ),
    FoodComponent(
        name: "Sodium Metabisulphite",
        aliases: ["sodium metabisulphite", "sodium metabisulfite", "ins 223", "ins223", "e223", "e 223"],
        category: .preservative,
        purpose: "Sulphite preservative used to prevent browning and spoilage.",
        riskLevel: .limit,
        explanation: "Sulphites can bother sensitive individuals.",
        advice: "Avoid if you are sulphite-sensitive; otherwise consume processed foods in limit."
    ),
    FoodComponent(
        name: "Tartrazine",
        aliases: ["tartrazine", "ins 102", "ins102", "e102", "e 102", "colour 102", "color 102"],
        category: .artificialColour,
        purpose: "Synthetic yellow food colour.",
        riskLevel: .limit,
        explanation: "Used to give yellow colour to packaged foods and drinks.",
        advice: "Consume occasionally, especially in children's snacks."
    ),
    FoodComponent(
        name: "Sunset Yellow",
        aliases: ["sunset yellow", "ins 110", "ins110", "e110", "e 110", "colour 110", "color 110"],
        category: .artificialColour,
        purpose: "Synthetic orange-yellow colour.",
        riskLevel: .limit,
        explanation: "Used in candies, drinks, desserts, and processed snacks.",
        advice: "Consume in limit."
    ),
    FoodComponent(
        name: "MSG",
        aliases: ["msg", "monosodium glutamate", "ins 621", "ins621", "e621", "e 621", "flavour enhancer 621", "flavor enhancer 621"],
        category: .flavourEnhancer,
        purpose: "Enhances savoury taste.",
        riskLevel: .limit,
        explanation: "Common flavour enhancer used in instant noodles, soups, and snacks.",
        advice: "Limit frequent intake of highly processed foods containing flavour enhancers."
    ),
    FoodComponent(
        name: "Aspartame",
        aliases: ["aspartame", "ins 951", "ins951", "e951", "e 951", "artificial sweetener 951"],
        category: .sweetener,
        purpose: "Low-calorie artificial sweetener.",
        riskLevel: .limit,
        explanation: "Used in diet drinks, gums, and sugar-free foods.",
        advice: "Consume in regulated limits and avoid if the label warning applies to you."
    ),
    FoodComponent(
        name: "Sucralose",
        aliases: ["sucralose", "ins 955", "ins955", "e955", "e 955", "artificial sweetener 955"],
        category: .sweetener,
        purpose: "Low-calorie artificial sweetener.",
        riskLevel: .limit,
        explanation: "Used in sugar-free packaged foods and drinks.",
        advice: "Consume occasionally rather than as a daily processed-food habit."
    ),
    FoodComponent(
        name: "Citric Acid",
        aliases: ["citric acid", "ins 330", "ins330", "e330", "e 330", "acidity regulator 330"],
        category: .ingredient,
        purpose: "Acidity regulator and flavour balancer.",
        riskLevel: .safe,
        explanation: "A common acidity regulator in packaged foods.",
        advice: "Usually low concern when used in normal packaged-food amounts."
    )
]

private let allergenAliases: [String: [String]] = [
    "Milk": ["milk", "milk solids", "casein", "whey", "lactose"],
    "Soy": ["soy", "soya", "soybean", "soy lecithin"],
    "Wheat": ["wheat", "wheat flour", "atta", "maida"],
    "Gluten": ["gluten", "barley", "rye"],
    "Peanut": ["peanut", "groundnut"],
    "Tree Nut": ["tree nut", "almond", "cashew", "walnut", "pistachio", "hazelnut"],
    "Egg": ["egg", "albumen"],
    "Fish": ["fish"],
    "Shellfish": ["shellfish", "crustacean", "shrimp", "prawn"],
    "Sesame": ["sesame", "til"]
]

private let micronutrients: [Micronutrient] = [
    Micronutrient(name: "Calcium", aliases: ["calcium", "ca"], role: "Supports bones and teeth."),
    Micronutrient(name: "Iron", aliases: ["iron", "fe"], role: "Helps in blood oxygen transport."),
    Micronutrient(name: "Vitamin C", aliases: ["vitamin c", "ascorbic acid"], role: "Supports immunity and skin health."),
    Micronutrient(name: "Vitamin D", aliases: ["vitamin d", "cholecalciferol"], role: "Supports bones and calcium absorption."),
    Micronutrient(name: "Vitamin A", aliases: ["vitamin a", "retinol"], role: "Supports vision and immunity."),
    Micronutrient(name: "Potassium", aliases: ["potassium"], role: "Supports fluid balance and muscle function."),
    Micronutrient(name: "Magnesium", aliases: ["magnesium"], role: "Supports muscles, nerves, and energy metabolism."),
    Micronutrient(name: "Zinc", aliases: ["zinc"], role: "Supports immunity and growth."),
    Micronutrient(name: "Sodium", aliases: ["sodium", "salt"], role: "Needed in small amounts, but excess intake should be limited.")
]

enum IngredientSafetyEngine {

    static func analyze(labelText: String, scanConfidence: Double? = nil) -> IngredientSafetyReport {

        let labelData = extractLabelData(from: labelText)
        let serving = extractServing(from: labelText)
        let nutritionSource = labelData.nutritionText ?? labelText
        let ingredientSource = [
            labelData.ingredientsText,
            labelData.allergenText,
            labelText
        ]
            .compactMap { $0 }
            .joined(separator: " ")

        let metrics = extractNutrition(from: nutritionSource, serving: serving)
        let detectedComponents = detectComponents(in: ingredientSource, database: componentDatabase)
        let detectedIngredients = detectedComponents.filter { $0.category == .ingredient }
        let detectedAdditives = detectedComponents.filter {
            [.preservative, .artificialColour, .sweetener, .flavourEnhancer].contains($0.category)
        }
        let detectedAllergens = detectAllergens(from: ingredientSource)
        let micronutrientReports = analyzeMicronutrients(in: nutritionSource + " " + labelText, metrics: metrics)
            .filter { $0.status != "Not detected" }

        var riskScore = 0
        var reasons: [String] = []

        for component in detectedComponents {
            switch component.category {
            case .artificialColour:
                riskScore += 2
                reasons.append("\(component.name) artificial colour found")
            case .preservative:
                riskScore += 1
                reasons.append("\(component.name) preservative found")
            case .sweetener, .flavourEnhancer:
                riskScore += 1
                reasons.append("\(component.name) \(component.category.rawValue.lowercased()) found")
            default:
                if component.riskLevel == .limit {
                    riskScore += 1
                    reasons.append("\(component.name) should be consumed in limit")
                } else if component.riskLevel == .avoid {
                    riskScore += 3
                    reasons.append("\(component.name) is not recommended")
                }
            }
        }

        for metric in metrics {
            let lower = metric.name.lowercased()
            if metric.status == "NOT SAFE" {
                riskScore += lower.contains("trans fat") ? 3 : 2
                reasons.append("\(metric.name) is high")
            } else if metric.status == "LIMIT", riskNutrients.contains(lower) {
                riskScore += 2
                reasons.append("\(metric.name) should be limited")
            }

            if metric.status == "GOOD" && (lower == "protein" || lower == "dietary fibre") {
                riskScore -= 1
                reasons.append("Good \(metric.name.lowercased()) content")
            }
        }

        if !detectedAllergens.isEmpty {
            riskScore += 3
            reasons.append("Allergen alert: \(detectedAllergens.joined(separator: ", "))")
        }

        if micronutrientReports.contains(where: { $0.status == "Present" || $0.status == "Good source" }) {
            riskScore -= 1
            reasons.append("Vitamins or minerals detected")
        }

        if let scanConfidence, scanConfidence < 0.65 {
            riskScore = max(riskScore, 2)
            reasons.insert("Low scan confidence; please rescan or edit the detected text", at: 0)
        }

        riskScore = max(0, riskScore)
        let decision = finalVerdict(score: riskScore)
        let uniqueReasons = unique(reasons)
        let warnings = buildWarnings(
            metrics: metrics,
            additives: detectedAdditives,
            allergens: detectedAllergens,
            confidence: scanConfidence
        )
        let summary = buildSummary(decision: decision, reasons: uniqueReasons, confidence: scanConfidence)
        let finalAdvice = buildFinalAdvice(decision: decision, reasons: uniqueReasons, confidence: scanConfidence)

        return IngredientSafetyReport(
            summary: summary,
            decision: decision,
            confidence: scanConfidence,
            riskScore: riskScore,
            reasons: Array(uniqueReasons.prefix(5)),
            warnings: Array(warnings.prefix(5)),
            labelData: labelData,
            detectedIngredients: detectedIngredients,
            detectedAdditives: detectedAdditives,
            detectedAllergens: detectedAllergens,
            nutritionMetrics: metrics,
            micronutrients: micronutrientReports,
            nutrientCount: metrics.count,
            finalAdvice: finalAdvice
        )
    }

    static func normalizeText(_ text: String) -> String {
        let separators = ["\n", "\r", "-", ":", ",", ".", "(", ")", "/", "\\", ";", "•", "[", "]"]
        var normalized = text.lowercased()
        for separator in separators {
            normalized = normalized.replacingOccurrences(of: separator, with: " ")
        }
        return normalized
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
    }

    static func fixOCRMistakes(_ text: String) -> String {
        text
            .replacingOccurrences(of: "1ns", with: "ins")
            .replacingOccurrences(of: "i ns", with: "ins")
            .replacingOccurrences(of: "lns", with: "ins")
            .replacingOccurrences(of: "sodlum", with: "sodium")
            .replacingOccurrences(of: "benzoatc", with: "benzoate")
            .replacingOccurrences(of: "tartrazlne", with: "tartrazine")
            .replacingOccurrences(of: "sulphlte", with: "sulphite")
            .replacingOccurrences(of: "metabisulphlte", with: "metabisulphite")
    }

    private static func extractLabelData(from text: String) -> FoodLabelData {
        let ingredients = extractSection(
            from: text,
            starts: ["ingredients", "ingredient"],
            stops: ["nutrition", "nutritional", "allergen", "contains", "may contain", "best before", "fssai", "manufactured"]
        )
        let nutrition = extractSection(
            from: text,
            starts: ["nutrition facts", "nutrition information", "nutritional information", "nutrition", "nutritional value"],
            stops: ["ingredients", "allergen", "contains", "may contain", "best before", "fssai", "manufactured"]
        )
        let allergen = extractSection(
            from: text,
            starts: ["allergen", "contains", "may contain"],
            stops: ["nutrition", "nutritional", "ingredients", "best before", "fssai", "manufactured"]
        )

        return FoodLabelData(
            rawText: text,
            cleanedText: fixOCRMistakes(normalizeText(text)),
            ingredientsText: ingredients,
            nutritionText: nutrition,
            allergenText: allergen
        )
    }

    private static func extractSection(
        from text: String,
        starts: [String],
        stops: [String],
        maxLength: Int = 900
    ) -> String? {
        let lower = text.lowercased()
        let startRange = starts
            .compactMap { lower.range(of: $0) }
            .min { $0.lowerBound < $1.lowerBound }
        guard let startRange else { return nil }

        let remainder = lower[startRange.upperBound...]
        var endIndex = remainder.endIndex
        for stop in stops {
            if let stopRange = remainder.range(of: stop),
               stopRange.lowerBound < endIndex {
                endIndex = stopRange.lowerBound
            }
        }

        let section = String(remainder[..<endIndex])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !section.isEmpty else { return nil }
        return String(section.prefix(maxLength))
    }

    private static func detectComponents(in text: String, database: [FoodComponent]) -> [FoodComponent] {
        let normalized = fixOCRMistakes(normalizeText(text))
        let compacted = normalized.replacingOccurrences(of: " ", with: "")

        return database.filter { component in
            component.aliases.contains { alias in
                containsAlias(alias, normalizedText: normalized, compactedText: compacted)
            }
        }
    }

    private static func detectAllergens(from text: String) -> [String] {
        let normalized = fixOCRMistakes(normalizeText(text))
        let compacted = normalized.replacingOccurrences(of: " ", with: "")

        let matches = allergenAliases.compactMap { name, aliases -> String? in
            let found = aliases.contains { alias in
                containsAlias(alias, normalizedText: normalized, compactedText: compacted)
            }
            return found ? name : nil
        }

        return matches.sorted()
    }

    private static func analyzeMicronutrients(in text: String, metrics: [NutritionMetric]) -> [MicronutrientReport] {
        let normalized = fixOCRMistakes(normalizeText(text))
        let metricMap = Dictionary(uniqueKeysWithValues: metrics.map { ($0.name.lowercased(), $0) })

        return micronutrients.map { micronutrient in
            let metric = metricMap[micronutrient.name.lowercased()]
            let foundInText = micronutrient.aliases.contains { alias in
                containsAlias(
                    alias,
                    normalizedText: normalized,
                    compactedText: normalized.replacingOccurrences(of: " ", with: "")
                )
            }

            let status: String
            if let metric {
                if metric.status == "NOT SAFE" || (metric.status == "LIMIT" && micronutrient.name == "Sodium") {
                    status = "High / limit"
                } else if metric.status == "LIMIT" {
                    status = "Good source"
                } else if metric.status == "GOOD" {
                    status = "Good source"
                } else {
                    status = "Present"
                }
            } else {
                status = foundInText ? "Present" : "Not detected"
            }

            return MicronutrientReport(
                name: micronutrient.name,
                status: status,
                role: micronutrient.role
            )
        }
    }

    private static func containsAlias(
        _ alias: String,
        normalizedText: String,
        compactedText: String
    ) -> Bool {
        let normalizedAlias = fixOCRMistakes(normalizeText(alias))
        guard !normalizedAlias.isEmpty else { return false }
        let compactAlias = normalizedAlias.replacingOccurrences(of: " ", with: "")
        if compactAlias.count <= 2 {
            return " \(normalizedText) ".contains(" \(normalizedAlias) ")
        }
        return normalizedText.contains(normalizedAlias) || compactedText.contains(compactAlias)
    }

    private static func finalVerdict(score: Int) -> OverallFoodDecision {
        if score <= 1 { return .safeToConsume }
        if score <= 5 { return .consumeOccasionally }
        return .notAdvised
    }

    private static func buildWarnings(
        metrics: [NutritionMetric],
        additives: [FoodComponent],
        allergens: [String],
        confidence: Double?
    ) -> [String] {
        var warnings: [String] = []
        if let confidence, confidence < 0.65 {
            warnings.append("Low scan confidence. Please rescan in better lighting or edit the detected text.")
        }
        warnings.append(contentsOf: metrics.filter { ["LIMIT", "NOT SAFE"].contains($0.status) }.map { "\($0.name): \(displayStatus($0.status))" })
        warnings.append(contentsOf: additives.map { "\($0.name): \($0.category.rawValue)" })
        if !allergens.isEmpty {
            warnings.append("Contains possible allergens: \(allergens.joined(separator: ", "))")
        }
        return unique(warnings)
    }

    private static func buildSummary(
        decision: OverallFoodDecision,
        reasons: [String],
        confidence: Double?
    ) -> String {
        if let confidence, confidence < 0.65 {
            return "Scan confidence is low. Review or rescan the label before trusting this result."
        }

        let reasonText = reasons.prefix(3).joined(separator: ", ")
        switch decision {
        case .safeToConsume:
            return reasonText.isEmpty
            ? "No major label concerns were detected in the scanned text."
            : "No major label concerns were detected. Helpful signals: \(reasonText)."
        case .consumeOccasionally:
            return reasonText.isEmpty
            ? "Some label signals suggest this product is better treated as an occasional food."
            : "Review the label carefully because \(reasonText)."
        case .notAdvised:
            return reasonText.isEmpty
            ? "The scanned label has multiple signals that need careful review."
            : "Review carefully because \(reasonText)."
        }
    }

    private static func buildFinalAdvice(
        decision: OverallFoodDecision,
        reasons: [String],
        confidence: Double?
    ) -> String {
        if let confidence, confidence < 0.65 {
            return "The OCR confidence is low, so this report should be treated as a draft. Rescan the label in better lighting or correct the detected text before making a decision."
        }

        let reasonText = reasons.prefix(3).joined(separator: ", ")
        switch decision {
        case .safeToConsume:
            return "Based on the scanned label, no major label concerns were found. Still check the package, expiry date, storage condition, recalls, and allergens before consuming."
        case .consumeOccasionally:
            return reasonText.isEmpty
            ? "Based on the scanned label, consider limiting frequent intake and compare the package with your dietary needs."
            : "Based on the scanned label, consider limiting frequent intake and reviewing \(reasonText)."
        case .notAdvised:
            return reasonText.isEmpty
            ? "Based on the scanned label, this product has several review signals. Verify the package details and consult an appropriate professional source if safety is uncertain."
            : "Based on the scanned label, verify this product carefully because \(reasonText). Consult an appropriate professional source if safety is uncertain."
        }
    }

    private static func unique(_ values: [String]) -> [String] {
        var seen: Set<String> = []
        var result: [String] = []
        for value in values {
            guard !seen.contains(value) else { continue }
            seen.insert(value)
            result.append(value)
        }
        return result
    }

    private static func displayStatus(_ status: String) -> String {
        switch status {
        case "NOT SAFE":
            return "HIGH"
        case "SAFE":
            return "OK"
        default:
            return status
        }
    }

    private static func extractNutrition(from text: String, serving: ServingInfo?) -> [NutritionMetric] {

        let clean = splitAtIngredients(text.lowercased())
        let hasDVColumn = clean.contains("% daily value") || clean.contains("daily value")
        let hasPer100Basis = clean.contains("per 100g") || clean.contains("per 100 g") || clean.contains("per 100ml") || clean.contains("per 100 ml")
        let lineTokens = clean
            .split(whereSeparator: { $0 == "\n" || $0 == "\r" })
            .map(String.init)

        let tokens = lineTokens.flatMap { line in
            line
                .replacingOccurrences(of: ";", with: ",")
                .replacingOccurrences(of: "•", with: ",")
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
        }

        let expandedTokens = tokens.flatMap { splitToken(String($0)) }

        var candidates: [ParsedCandidate] = []

        var index = 0
        while index < expandedTokens.count {
            let token = expandedTokens[index]
            defer { index += 1 }
            if !hasNutritionKeyword(token) { continue }
            if token.contains("calories from") { continue }
            if token.contains("other") && token.contains("carbohydrate") { continue }
            guard var parsed = parseCandidate(token) else { continue }

            if parsed.percent == nil {
                var lookahead = 1
                while index + lookahead < expandedTokens.count && lookahead <= 3 {
                    let next = expandedTokens[index + lookahead]
                    if let trailing = parsePercentOnly(from: next, requireMarker: !hasDVColumn) {
                        parsed = (parsed.name, parsed.value, parsed.unit, trailing)
                        index += lookahead
                        break
                    }
                    lookahead += 1
                }
            }
            if parsed.percent == nil, hasDVColumn {
                // Allow percent without '%' when a DV column is present.
                if let trailing = parseTrailingPercent(from: token, requireMarker: false) {
                    parsed = (parsed.name, parsed.value, parsed.unit, trailing)
                }
            }

            let normalized = normalize(parsed.name)
            guard supportedNutrients.contains(normalized) else { continue }

            let isPer100g = token.contains("per 100") || (serving == nil && hasPer100Basis)

            let perServeValue: Double?
            let per100gValue: Double?
            let unit: String?
            if let value = parsed.value, let unitRaw = parsed.unit {
                let converted = convertIfNeeded(value: value, unit: unitRaw, nutrient: normalized)
                perServeValue =
                    isPer100g && serving == nil ? nil :
                    serving == nil ? converted.value :
                    isPer100g ? (converted.value / 100) * serving!.value :
                    converted.value
                per100gValue = isPer100g ? converted.value : nil
                unit = converted.unit
            } else {
                perServeValue = nil
                per100gValue = nil
                unit = nil
            }

            var dvPercent = parsed.percent
            if normalized == "energy", let dv = dvPercent, dv > 200 {
                dvPercent = nil
            }
            let rdaPercent: Double? = {
                guard let value = perServeValue,
                      let unit = unit,
                      let rda = rdaTable[normalized],
                      unit == rda.unit else { return nil }
                return (value / rda.value) * 100
            }()

            candidates.append(
                ParsedCandidate(
                    nutrient: normalized,
                    token: token,
                    perServeValue: perServeValue,
                    per100gValue: per100gValue,
                    unit: unit,
                    dvPercent: dvPercent,
                    rdaPercent: rdaPercent
                )
            )
        }
        var result: [NutritionMetric] = []
        let grouped = Dictionary(grouping: candidates, by: { $0.nutrient })
        for (nutrient, items) in grouped {
            guard let best = selectBest(items, nutrient: nutrient) else { continue }
            let percentForStatus = best.dvPercent ?? best.rdaPercent
            guard percentForStatus != nil || best.perServeValue != nil || best.per100gValue != nil else { continue }
            let metricStatus = status(
                from: percentForStatus,
                computedPercent: best.rdaPercent,
                nutrient: nutrient,
                value: best.perServeValue ?? best.per100gValue,
                unit: best.unit
            )
            result.append(
                NutritionMetric(
                    name: nutrient.capitalized,
                    perServe: best.perServeValue.flatMap { value in best.unit.map { "\(round(value * 10) / 10) \($0)" } },
                    per100g: best.per100gValue.flatMap { value in best.unit.map { "\(round(value * 10) / 10) \($0)" } },
                    dvPercent: best.dvPercent.map { "\(Int($0))%" },
                    rdaPercent: best.rdaPercent.map { "\(Int($0))%" },
                    status: metricStatus
                )
            )
        }

        return result.sorted { $0.name < $1.name }
    }

    private static func status(
        from percent: Double?,
        computedPercent: Double?,
        nutrient: String,
        value: Double?,
        unit: String?
    ) -> String {
        if let value, let unit {
            if nutrient == "total sugars" || nutrient == "added sugar" {
                if unit == "g", value > 15 { return "LIMIT" }
            }
            if nutrient == "sodium" {
                if unit == "mg", value > 400 { return "LIMIT" }
                if unit == "g", value > 0.4 { return "LIMIT" }
            }
            if nutrient == "saturated fat", unit == "g", value > 5 {
                return "LIMIT"
            }
            if nutrient == "trans fat", unit == "g", value > 0 {
                return "NOT SAFE"
            }
            if nutrient == "dietary fibre", unit == "g" {
                return value >= 3 ? "GOOD" : "LOW"
            }
            if nutrient == "protein", unit == "g" {
                return value >= 5 ? "GOOD" : "LOW"
            }
        }

        // %DV guidance: 5% or less = low, 20% or more = high.
        // Higher-attention nutrients: if per-serving (computed) hits the daily reference, flag for review.
        guard let percent else { return "SAFE" }
        if riskNutrients.contains(nutrient) {
            if let computed = computedPercent, computed >= 100 { return "NOT SAFE" }
            if percent >= 100 { return "NOT SAFE" }
            if percent >= 20 { return "LIMIT" }
            return "SAFE"
        }
        if beneficialNutrients.contains(nutrient) {
            if let computed = computedPercent, computed >= 100 { return "LIMIT" }
            if percent >= 100 { return "LIMIT" }
            return "SAFE"
        }
        if let computed = computedPercent, computed >= 100 { return "NOT SAFE" }
        if percent >= 100 { return "NOT SAFE" }
        if percent >= 20 { return "LIMIT" }
        return "SAFE"
    }

    private static func normalize(_ name: String) -> String {
        let key = name.lowercased().trimmingCharacters(in: .whitespaces)
        if key.contains("saturated") && key.contains("fat") { return "saturated fat" }
        if key.contains("trans") && key.contains("fat") { return "trans fat" }
        if key.contains("added") && key.contains("sugar") { return "added sugar" }
        if key.contains("total sugar") || key == "sugar" || key == "sugars" { return "total sugars" }
        if key.contains("dietary") && (key.contains("fiber") || key.contains("fibre")) { return "dietary fibre" }
        if key.contains("total fat") || key == "fat" { return "total fat" }
        if key.contains("carbohydrate") || key.contains("carbs") { return "carbohydrate" }
        if key.contains("cholesterol") { return "cholesterol" }
        return nutrientAlias[key] ?? key
    }

    private static func parseCandidate(_ text: String) -> (name: String, value: Double?, unit: String?, percent: Double?)? {

        var percent = parsePercent(from: text)
        let valueUnitRegex = try? NSRegularExpression(
            pattern: #"([0-9]+(?:\.[0-9]+)?)\s*(mg|g|mcg|ug|µg|kcal|kj)"#,
            options: .caseInsensitive
        )

        var value: Double?
        var unit: String?

        if let m = valueUnitRegex?.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let v = Range(m.range(at: 1), in: text),
           let u = Range(m.range(at: 2), in: text),
           let parsedValue = Double(text[v]) {
            value = parsedValue
            unit = normalizeUnit(String(text[u]))
        }

        if percent == nil {
            percent = parseTrailingPercent(from: text, requireMarker: true)
        }

        var name = text
        if let m = valueUnitRegex?.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let r = Range(m.range, in: text) {
            name.removeSubrange(r)
        }

        if percent != nil {
            let percentRegex = try? NSRegularExpression(
                pattern: #"([0-9]+(?:\.[0-9]+)?)\s*(%|\%[*]|percent|per\s*cent)"#,
                options: .caseInsensitive
            )
            if let percentRegex {
                name = percentRegex.stringByReplacingMatches(
                    in: name,
                    range: NSRange(name.startIndex..., in: name),
                    withTemplate: ""
                )
            }
            let trailingNumber = try? NSRegularExpression(
                pattern: #"\s+[0-9]{1,3}\s*$"#,
                options: .caseInsensitive
            )
            if let trailingNumber {
                name = trailingNumber.stringByReplacingMatches(
                    in: name,
                    range: NSRange(name.startIndex..., in: name),
                    withTemplate: ""
                )
            }
        }

        name = name
            .replacingOccurrences(of: "%", with: "")
            .replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: "per serving", with: "")
            .replacingOccurrences(of: "per serve", with: "")
            .replacingOccurrences(of: "per 100 g", with: "")
            .replacingOccurrences(of: "per 100g", with: "")
            .replacingOccurrences(of: "per 100ml", with: "")
            .replacingOccurrences(of: "per 100 ml", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty else { return nil }
        return (name, value, unit, percent)
    }

    private static func extractServing(from text: String) -> ServingInfo? {
        let regex = try? NSRegularExpression(
            pattern: #"serving size\s*[:\-]?\s*([0-9]+(?:\.[0-9]+)?)\s*(g|ml)"#,
            options: .caseInsensitive
        )

        guard let m = regex?.firstMatch(
            in: text,
            range: NSRange(text.startIndex..., in: text)
        ),
        let v = Range(m.range(at: 1), in: text),
        let u = Range(m.range(at: 2), in: text),
        let value = Double(text[v]) else { return nil }

        return ServingInfo(value: value, unit: String(text[u]))
    }

    private static func splitAtIngredients(_ text: String) -> String {
        let pattern = #"\b(ingredients|contains|manufactured|may contain)\b"#
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        guard let regex else { return text }

        let range = NSRange(text.startIndex..., in: text)
        if let match = regex.firstMatch(in: text, range: range),
           let r = Range(match.range, in: text) {
            return String(text[..<r.lowerBound])
        }
        return text
    }

    private static func parsePercent(from text: String) -> Double? {
        let regex = try? NSRegularExpression(
            pattern: #"([0-9]+(?:\.[0-9]+)?)\s*(%|\%[*]|percent|per\s*cent)"#,
            options: .caseInsensitive
        )
        guard let m = regex?.firstMatch(
            in: text,
            range: NSRange(text.startIndex..., in: text)
        ),
        let v = Range(m.range(at: 1), in: text),
        let value = Double(text[v]) else { return nil }
        return value
    }

    private static func parseTrailingPercent(from text: String, requireMarker: Bool) -> Double? {
        if requireMarker && !containsPercent(text) { return nil }
        let regex = try? NSRegularExpression(
            pattern: #"([0-9]+(?:\.[0-9]+)?)\s*(mg|g|mcg|ug|µg|kcal|kj)\s*([0-9]{1,3})(?:\s*(%|\%[*]|percent|per\s*cent))?"#,
            options: .caseInsensitive
        )
        guard let m = regex?.firstMatch(
            in: text,
            range: NSRange(text.startIndex..., in: text)
        ),
        let v = Range(m.range(at: 3), in: text),
        let value = Double(text[v]) else { return nil }
        return value
    }

    private static func parsePercentOnly(from text: String, requireMarker: Bool) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if requireMarker && !containsPercent(trimmed) { return nil }
        let regex = try? NSRegularExpression(
            pattern: #"^([0-9]{1,3}(?:\.[0-9]+)?)\s*(%|\%[*]|percent|per\s*cent)?$"#,
            options: .caseInsensitive
        )
        guard let m = regex?.firstMatch(
            in: trimmed,
            range: NSRange(trimmed.startIndex..., in: trimmed)
        ),
        let v = Range(m.range(at: 1), in: trimmed),
        let value = Double(trimmed[v]) else { return nil }
        return value
    }

    private static func normalizeUnit(_ unit: String) -> String {
        let lower = unit.lowercased()
        if lower == "ug" || lower == "µg" { return "mcg" }
        return lower
    }

    private static func convertIfNeeded(value: Double, unit: String, nutrient: String) -> (value: Double, unit: String) {
        if unit == "kj", let rda = rdaTable[nutrient], rda.unit == "kcal" {
            return (value / 4.184, "kcal")
        }
        return (value, unit)
    }

    private static func splitToken(_ token: String) -> [String] {
        let pattern = "(?=\\b(" + nutritionKeywords.map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "|") + ")\\b)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return [token]
        }

        let ns = token as NSString
        let matches = regex.matches(in: token, range: NSRange(location: 0, length: ns.length))
        guard matches.count > 1 else { return [token] }

        var parts: [String] = []
        for (index, match) in matches.enumerated() {
            let start = match.range.location
            let end = index + 1 < matches.count ? matches[index + 1].range.location : ns.length
            let slice = ns.substring(with: NSRange(location: start, length: end - start))
            let trimmed = slice.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                parts.append(trimmed)
            }
        }
        return parts.isEmpty ? [token] : parts
    }

    private static func hasNutritionKeyword(_ token: String) -> Bool {
        let lower = token.lowercased()
        return nutritionKeywords.contains { lower.contains($0) }
    }

    private static func containsPercent(_ text: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: #"\d+\s*(%|\%[*]|percent|per\s*cent)"#, options: .caseInsensitive)
        return regex?.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }

    private static func selectBest(_ items: [ParsedCandidate], nutrient: String) -> ParsedCandidate? {
        guard !items.isEmpty else { return nil }
        let isCarb = nutrient == "carbohydrate"
        let isSugar = nutrient == "total sugars" || nutrient == "added sugar"

        func score(_ item: ParsedCandidate) -> Int {
            var s = 0
            let token = item.token
            if item.dvPercent != nil { s += 5 }
            if item.perServeValue != nil || item.per100gValue != nil { s += 1 }
            if isCarb || isSugar {
                if token.contains("total") { s += 2 }
                if token.contains("other") { s -= 3 }
            }
            if nutrient == "added sugar" && token.contains("added") { s += 2 }
            if nutrient == "total sugars" && token.contains("added") { s -= 2 }
            if let dv = item.dvPercent, dv > 200, nutrient != "energy" { s -= 2 }
            return s
        }

        return items.max { a, b in
            let sa = score(a)
            let sb = score(b)
            if sa != sb { return sa < sb }
            let va = a.perServeValue ?? a.per100gValue ?? 0
            let vb = b.perServeValue ?? b.per100gValue ?? 0
            return va < vb
        }
    }

    static func looksLikeNutritionLabel(_ labelText: String) -> Bool {
        let lower = labelText.lowercased()
        if lower.contains("nutrition facts") || lower.contains("nutrition information") {
            return true
        }
        if lower.contains("ingredients") || lower.contains("allergen") || lower.contains("may contain") {
            return true
        }
        if lower.contains("ins ") || lower.contains("ins-") || lower.contains("preservative") || lower.contains("flavour enhancer") {
            return true
        }
        if lower.contains("serving size") || lower.contains("amount per serving") {
            return true
        }
        if containsPercent(lower) {
            return true
        }
        let matches = nutritionKeywords.filter { lower.contains($0) }.count
        return matches >= 2
    }
}
